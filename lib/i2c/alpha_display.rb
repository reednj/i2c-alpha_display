require "i2c/alpha_display/version"
require "i2c/alpha_display/hardware"
require "i2c/alpha_display/extensions"

module I2C
  class AlphaDisplay
    DEVICE_ID = 0x70

    HT16K33_SYSTEM_SETUP = 0x20
    HT16K33_OSCILLATOR	= 0x01
    HT16K33_CMD_BRIGHTNESS = 0xE0

    HT16K33_BLINK_CMD = 0x80
    HT16K33_BLINK_DISPLAYON	= 0x01
    HT16K33_BLINK_OFF = 0x00
    HT16K33_BLINK_2HZ = 0x02
    HT16K33_BLINK_1HZ = 0x04
    HT16K33_BLINK_HALFHZ = 0x06

    DIGIT_VALUES = {
      ' ' => 0b0000000000000000,
      '+' => 0b0001001011000000,
      '-' => 0b0000000011000000,
      '0' => 0b0000110000111111,
      '1' => 0b0000000000000110,
      '2' => 0b0000000011011011,
      '3' => 0b0000000010001111,
      '4' => 0b0000000011100110,
      '5' => 0b0010000001101001,
      '6' => 0b0000000011111101,
      '7' => 0b0000000000000111,
      '8' => 0b0000000011111111,
      '9' => 0b0000000011101111,
      'A' => 0b0000000011110111,
      'B' => 0b0001001010001111,
      'C' => 0b0000000000111001,
      'D' => 0b0001001000001111,
      'E' => 0b0000000011111001,
      'F' => 0b0000000001110001,
      'G' => 0b0000000010111101,
      'H' => 0b0000000011110110,
      'I' => 0b0001001000000000,
      'J' => 0b0000000000011110,
      'K' => 0b0010010001110000,
      'L' => 0b0000000000111000,
      'M' => 0b0000010100110110,
      'N' => 0b0010000100110110,
      'O' => 0b0000000000111111,
      'P' => 0b0000000011110011,
      'Q' => 0b0010000000111111,
      'R' => 0b0010000011110011,
      'S' => 0b0000000011101101,
      'T' => 0b0001001000000001,
      'U' => 0b0000000000111110,
      'V' => 0b0000110000110000,
      'W' => 0b0010100000110110,
      'X' => 0b0010110100000000,
      'Y' => 0b0001010100000000,
      'Z' => 0b0000110000001001	
    }

    attr_accessor :debug

    def initialize(device_id = DEVICE_ID, should_init = true)
      @display_size = 4
      @device = WiringPi::I2C.new device_id
      @buffer_size = 16
      @buffer = []
      @device_id = device_id

      self.debug = false
      self.clear

      # init the device to the default state, if thats what we want
      if should_init
        self.display_init
      end
    end

    def display_init
      @device.write HT16K33_SYSTEM_SETUP | HT16K33_OSCILLATOR
      self.stop_blink
      self.brightness = 1
    end

    def self.open(device_id = DEVICE_ID)
      return AlphaDisplay.new(device_id, false)
    end


    def blank()
      self.clear()
      self.write_buffer
    end

    def clear()
      @buffer_size.times do |i|
        @buffer[i] = 0
      end
    end

    def brightness=(v)
      @device.write HT16K33_CMD_BRIGHTNESS | (v.to_i & 0xf)
    end

    def start_blink(type = HT16K33_BLINK_1HZ)
      self.blink = type
    end

    def stop_blink
      self.blink = HT16K33_BLINK_OFF
    end

    def blink=(v)
      raise if ![HT16K33_BLINK_OFF, HT16K33_BLINK_2HZ, HT16K33_BLINK_1HZ, HT16K33_BLINK_HALFHZ].include? v
      @device.write HT16K33_BLINK_CMD | HT16K33_BLINK_DISPLAYON | v.to_i
    end

    def set(s, rjust = true)
      if s.respond_to? :to_alpha
        s = s.to_alpha
      end
      
      s = s.to_s
      s_no_decimals = s.gsub('.', '')

      puts s if self.debug

      if rjust && s_no_decimals.length < @display_size
        decimal_count = s.length - s_no_decimals.length
        s = s.rjust(@display_size + decimal_count)
      end

      addr = 0
      (0..s.length-1).each do |pos|
        next if s[pos] == '.'

        decimal = (s[pos+1] == '.' && addr != @display_size -1)
        write_char addr, s[pos], decimal
        addr += 1

        break if addr >= @display_size
      end

      self.write_buffer
    end

    def write_char(pos, c, decimal = false)
      raise "Invalid address (#{pos})" if pos >= @display_size || pos.class != Fixnum
      raise "Expecting string data, but got #{c.class}" if c.class != String
      raise "Can only set a single character (string length is #{c.length})" if c.length != 1

      a = DIGIT_VALUES[c.upcase[0]]
      raise "Character not in character set (#{c})" if a.nil?
      
      a = a | 0x4000 if decimal
      @buffer[pos*2] = a & 0xff
      @buffer[pos*2+1] = (a >> 8) & 0xff
    end

    def write_buffer
      @buffer_size.times do |i|
        @device.write_reg_8 i, @buffer[i] & 0xFF
      end
    end

  end
end
