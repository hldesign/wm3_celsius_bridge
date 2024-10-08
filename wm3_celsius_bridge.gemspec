# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wm3_celsius_bridge/version"

Gem::Specification.new do |spec|
  spec.name          = "wm3_celsius_bridge"
  spec.version       = Wm3CelsiusBridge::VERSION
  spec.authors       = ["Tobias Lindholm"]
  spec.email         = ["tobias.lindholm@hldesign.se"]

  spec.summary       = "WM3 Celsius Bridge"
  spec.description   = "WM3 NAV integration."
  spec.homepage      = "http://celsius.wm3.se"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-types", "0.14.0"
  spec.add_dependency "dry-struct", "0.4.0"
  spec.add_dependency "rubyntlm", "~> 0.6.2"
  spec.add_dependency "savon", "~> 2.11.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.11.3"
  spec.add_development_dependency "awesome_print"
end
