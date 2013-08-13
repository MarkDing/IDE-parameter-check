require 'find'
require 'fileutils'

class SilabsWSP
	@@key_words = [
	"Vendor=",
	"HITECHPRO=",
	"Assembler=",
	"AssFlag=",
	"Compiler=",
	"CompFlag=",
	"Linker=",
	"LinkFlag=",
	"LinkFormat=",
	"HexGenerator="
	]

	@@key_contents = {
	"Vendor=" => "0\n",
	"HITECHPRO=" => "0\n",
	"Assembler=" => "C:\\Keil\\C51\\BIN\\A51.EXE\n",
	"AssFlag=" => "XR GEN DB EP NOMOD51\n",
	"Compiler=" => "C:\\Keil\\C51\\BIN\\C51.EXE\n",
	"CompFlag=" => "DB OE BR\n",
	"Linker=" => "C:\\Keil\\C51\\BIN\\BL51.EXE\n",
	"LinkFlag=" => "RS(256) PL(68) PW(78)\n",
	"LinkFormat=" => "<Executable Name> <Input File(s)> TO <Output File> <Flags>\n",
	"HexGenerator=" => "C:\\Keil\\C51\\BIN\\OH51.EXE\n"
	}
	
	@@restore_default_setting = 0
	
	@@headfile_dir = "C:/Silabs/MCU/INC"
	
	def initialize(path)
		@path = path
	end

	def find_mcu_headfile(cur_dir)
		Find.find(cur_dir) do |fn|
			ext_name = File.extname(fn)
			if ext_name == ".c" or ext_name == ".h"
				f = File.open(fn, "r+")
				lines = f.readlines
				lines.each do |line|
					if line.include?"#include"
						a = /[cC]8051[fF]\d{3}.[hH]/.match(line)
						a = /[cC]8051[fF]\d{3}_[dD][eE][fF][sS].[hH]/.match(line) if not a 
						if a 
							headfile = "/" + a[0]
							dst = cur_dir + headfile 
							src = @@headfile_dir + headfile
							if not File.exist?(dst) 
								FileUtils.cp(src, dst)
								p "Copy #{a[0]} to " + dst
							end
							f.close
							return
						end
					end
				end
				f.close
			end
		end
	end
	
	def copy_head_files(fn)
		cur_dir = File.dirname(fn)
		# compiler_defs.h
		dst = cur_dir + "/compiler_defs.h" 
		src = @@headfile_dir + "/compiler_defs.h"
		if not File.exist?(dst) 
			FileUtils.cp(src, dst)
			p "Copy compiler_defs.h to " + dst
		end
		# C8051Fxxx_defs.h or C8051Fxxx.h
		find_mcu_headfile(cur_dir)
	end
	
	def handle_contents(line, a)
		new_line = line
		if @@restore_default_setting == 1
#			new_line = a + @@key_contents[a]
		else
			case a
			when "Vendor="
				p "The Tool Definition Presets is selecting preset"
				@@restore_default_setting = 1
				#new_line = a + @@key_contents[a]
			when "AssFlag=", "CompFlag="
				if line.include?" INCDIR"
					tmp = line.split(" ")
					new_line = ""
					tmp.each do |l|
						if not l.include?"INCDIR"
							new_line += l + " "
						end
					end
					new_line = new_line.strip + "\n"
				end
			when "Assembler=","Compiler=", "Linker=", "HexGenerator="
				new_line = a + @@key_contents[a]
			end
		end
		
		if new_line != line
			p "Org: " + line
			p "New: " + new_line
		end
		return new_line
	end

	def check_contents(fn)
		f = File.open(fn, "r+")
		lines = f.readlines
		i = 0
		while i < lines.size do
			line = lines[i]
			@@key_words.each do |a|
				if line.include?a
					data = line.split("=")
					if data[1].upcase != @@key_contents[a].upcase
						lines[i] = handle_contents(line,a)
					end
				end
			end
			i += 1
		end
		f.close
		
		copy_head_files(fn)
		if @@restore_default_setting == 0
			f = File.new(fn, "w+")
			f.puts lines
			f.close
		end
		p "**********************************************************************"
	end

	def find_wsp
		Find.find(@path) do |fn|
			if File.extname(fn) == ".wsp"
				p fn
				@@restore_default_setting = 0
				check_contents(fn)
			end
		end
	end
end


wsp = SilabsWSP.new("./")

wsp.find_wsp