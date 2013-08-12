require 'find'


class SilabsWSP
    @@key_words = [
    "Assembler=",
    "AssFlag=",
    "Compiler=",
    "CompFlag=",
    "Linker="
    ]
    
    @@key_contents = {
    "Assembler=" => "C:\\Keil\\C51\\BIN\\A51.EXE\r\n",
    "AssFlag=" => "XR GEN DB EP NOMOD51\r\n",
    "Compiler=" => "C:\\Keil\\C51\\BIN\\c51.exe\r\n",
    "CompFlag=" => "DB OE BR\r\n",
    "Linker=" => "C:\\Keil\\C51\\BIN\\BL51.EXE\r\n"
    }

    def initialize(path)
        @path = path
    end
    
    def handle_contents(line, a)
        new_line = line
        if a == "AssFlag=" or a == "CompFlag="
            if line.include?" INCDIR"
                new_line = line.split(" INCDIR")[0] + "\r\n"
            end
        else
            new_line = a + @@key_contents[a]
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
                    data = line.chomp.split("=")
                    if data[1] != @@key_contents[a].chomp
                        lines[i] = handle_contents(line,a)
                    end
                end
            end
            i += 1
        end
        p "**********************************************************************"
        f.seek(0)
        puts lines
        f.close
    end
    
    def find_wsp
        Find.find(@path) do |fn|
            if File.extname(fn) == ".wsp"
                p fn
                check_contents(fn)
            end
        end
    end
end


wsp = SilabsWSP.new("./")

wsp.find_wsp