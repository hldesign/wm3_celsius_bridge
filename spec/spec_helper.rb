# frozen_string_literal: true

require "bundler/setup"
require "savon/mock/spec_helper"
require "wm3_celsius_bridge"

# Silence celsius logger during tests
Wm3CelsiusBridge.logger = Logger.new(nil)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include(Savon::SpecHelper, soap: true)
  config.around(:each, soap: true) do |example|
    savon.mock!
    example.run
    savon.unmock!
  end
end
