# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fedex/version"
require "rake"

Gem::Specification.new do |s|
  s.name        = "fedex-web-services"
  s.version     = Fedex::VERSION
  s.authors     = ["Brian Abreu"]
  s.email       = ["brian@nut.com"]
  s.homepage    = "https://github.com/brewski/fedex-web-services"
  s.summary     = %q{Provies an interface to the FedEx web services API (version 10)}
  s.description = %q{Interfaces with the FedEx web services API to look up shipping rates, generate labels, and cancel shipments}

  s.rubyforge_project = "fedex-web-services"

  s.files         = FileList[ "lib/**/*" ]
  s.test_files    = [ ]
  s.executables   = [ ]
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
