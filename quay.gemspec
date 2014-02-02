# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quay/version'

Gem::Specification.new do |spec|
  spec.name          = "quay"
  spec.version       = Quay::VERSION
  spec.authors       = ["Tony Pitluga"]
  spec.email         = ["tony.pitluga@gmail.com"]
  spec.summary       = %q{automating docker dev environments}
  spec.description   = %q{automation for docker dev environments}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.18.1"
  spec.add_dependency "docker-api", "~> 1.7.6"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1.1"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
