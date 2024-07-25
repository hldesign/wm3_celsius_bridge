# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
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

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select do |file|
      file.match(%r{^(lib/*|README|LICENSE|CHANGELOG)})
    end
  end
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-struct" # , "0.4.0"
  spec.add_dependency "dry-types" # , "0.14.0"
  spec.add_dependency "rubyntlm" # , "~> 0.6.2"
  spec.add_dependency "savon" # , "~> 2.11.1"

  spec.required_ruby_version = ">= 3.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
