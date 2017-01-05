# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i2c/alpha_display/version'

Gem::Specification.new do |spec|
  spec.name          = "i2c-alpha_display"
  spec.version       = I2C::AlphaDisplay::VERSION
  spec.authors       = ["Nathan Reed"]
  spec.email         = ["reednj@gmail.com"]

  spec.summary       = %q{command line gem to control the i2c alphanumeric displays on the RPi}
  spec.homepage      = "https://github.com/reednj/i2c-alpha_display"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "wiringpi2"
  spec.add_dependency "trollop"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
