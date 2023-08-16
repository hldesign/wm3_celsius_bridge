# frozen_string_literal: true

require "wm3_celsius_bridge/models/customer"

RSpec.describe Wm3CelsiusBridge::Customer do
  let(:customer) { described_class.new(data) }

  context "with valid data" do
    let(:data) { YAML.load_file("spec/fixtures/customer_valid_data.yml") }

    it "parses customer data" do
      expect { customer }.not_to raise_error
    end
  end

  context "with missing customer number" do
    let(:data) { YAML.load_file("spec/fixtures/customer_missing_no.yml") }

    it "throws exception" do
      expect { customer }.to raise_error(Dry::Struct::Error)
    end
  end
end
