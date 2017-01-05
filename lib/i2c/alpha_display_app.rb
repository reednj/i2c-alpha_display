require 'trollop'
require 'i2c/alpha_display'

module I2C
    class AlphaDisplayApp
        def main
            opts = Trollop::options do
                version "i2c-disp #{AlphaDisplay::VERSION} (c) 2016 @reednj (reednj@gmail.com)"
                banner "Usage: i2c-disp [options]"
                opt :device, "I2C device id for the display", :type => :integer, :default => 0x70
            end

            @display = AlphaDisplay.new(opts[:device])

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

