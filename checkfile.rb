require 'find'


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
	"LinkFormat="
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
	"LinkFormat=" => "<Executable Name> <Input File(s)> TO <Output File> <Flags>\n"
	}
	
	@@restore_default_setting = 0
	
	def initialize(path)
		@path = path
	end

	def handle_contents(line, a)
		new_line = line
		if @@restore_default_setting == 1
			new_line = a + @@key_contents[a]
		elsif
			case a
			when "Vendor="
				p "The Tool Definition Presets is selecting preset"
				@@restore_default_setting = 1
				new_line = a + @@key_contents[a]
			when "AssFlag=", "CompFlag="
				if line.include?" INCDIR"
					new_line = line.split(" INCDIR")[0] + "\n"
				end
			when "Assembler=","Compiler=", "Linker="
				new_line = a + @@key_contents[a]
			end
		end
		
		if new_line != line
			p line
			p new_line
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
		p "**********************************************************************"
		f.seek(0)
		#line_count = 1
		#lines.each do |line|
			#puts line
		#	puts line_count
		#	f.print line
		#	line_count += 1
		#end
		#f.puts lines
		f.close
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