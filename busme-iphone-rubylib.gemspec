# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'busme/iphone/rubylib/version'

Gem::Specification.new do |spec|
  spec.name          = "busme-iphone-rubylib"
  spec.version       = Busme::Iphone::Rubylib::VERSION
  spec.authors       = ["Polar Humenn"]
  spec.email         = ["polar@adiron.com"]
  spec.description   = %q{nothing yet}
  spec.summary       = %q{nothing yet}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "httpclient", "~> 2.1.5"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
