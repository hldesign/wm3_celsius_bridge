# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::ParseChillers do
  let(:result) { Wm3CelsiusBridge::ParseChillers.new(data).call }

  before do
    allow(Wm3CelsiusBridge::Chiller).to receive(:new) do |arg|
      arg[:valid] ? arg : raise(ArgumentError.new('Invalid arg.'))
    end
  end

  context "with valid data" do
    let(:data) do
      [
        { no: "1", serial_no: "11", valid: true },
        { no: "2", serial_no: "22", valid: true },
        { no: "3", serial_no: "33", valid: true }
      ]
    end

    it "parses all chiller data" do
      expect(result.size).to eq(data.size)
    end
  end

  context "with invalid data" do
    let(:data) do
      [
        { no: "1", serial_no: "11", valid: true },
        { no: "2", serial_no: "22", valid: false },
        { no: "3", serial_no: "33", valid: true }
      ]
    end

    it "parses only valid chiller data" do
      expect(result.size).to eq(2)
    end
  end
end
