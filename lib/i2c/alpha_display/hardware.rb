begin
	require 'wiringpi2'
	GPIO_SIMULATED = false
	module WiringPi
		class I2C
			Wiringpi = Wiringpi2
		end
	end
rescue Exception => e
    module WiringPi
        class I2C
            def initialize(device)
                puts 'wiringpi2 not present, using mock class'
            end
            
            def write(data)
            end

            def write_reg_8(reg, data)
            end
        end
    end
end
