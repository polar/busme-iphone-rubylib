# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'busme/iphone/rubylib/version'

Gem::Specification.new do |spec|
  spec.name          = "busme-iphone-rubylib"
  spec.version       = Busme::Iphone::Rubylib::VERSION
  spec.authors       = ["Polar Humenn"]
  spec.email         = ["polar@adiron.com"]
  spec.description   = %q{Ruby Classes for iPhone/Android RubyMotion development}
  spec.summary       = %q{To be used with Ruby Motion}
  spec.homepage      = "http://busme.us"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "httpclient", "~> 2.1"
  spec.add_runtime_dependency "pqueue", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 3.1"
end
