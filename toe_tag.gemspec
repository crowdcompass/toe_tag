# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toe_tag/version'

Gem::Specification.new do |spec|
  spec.name          = "toe_tag"
  spec.version       = ToeTag::VERSION
  spec.authors       = ["Matthew Boeh"]
  spec.email         = ["matt@crowdcompass.com"]
  spec.description   = %q{Utilities for catching and handling exceptions.}
  spec.summary       = %q{Utilities for catching and handling exceptions.}
  spec.homepage      = "https://github.com/crowdcompass/toe_tag"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0"
end
