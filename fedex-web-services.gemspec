# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fedex_web_services/version'

Gem::Specification.new do |spec|
  spec.name          = "fedex-web-services"
  spec.version       = FedexWebServices::VERSION
  spec.authors       = ["Brian Abreu"]
  spec.email         = ["brian@nuts.com"]
  spec.description   = %q{Interfaces with the FedEx SOAP web services API}
  spec.summary       = %q{Provides an interface to the FedEx web services API}
  spec.homepage      = "https://github.com/brewski/fedex-web-services"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "soap4r-ng", '~> 2.0'
  spec.add_dependency "rake"
  spec.add_dependency "logger-application"
  spec.required_ruby_version = '>= 2.0.4'
end
