
require 'i2c/alpha_display'

module I2C
    class AlphaDisplayApp
        def main
            @display = AlphaDisplay.new(0x70)

            STDIN.each_line do |line|
                begin
                    a = parse_line(line)
                    @display.set a
                rescue => e
                    puts e.to_s
                end
            end
            
        end

        def parse_line(s)
            s.strip!

            if s.to_i.to_s == s
                return s.to_i
            end

            begin
                return Float(s)
            rescue
                return s
            end
        end
    end
end

