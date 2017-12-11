# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::ParseItems do
  let(:result) do
    Wm3CelsiusBridge::ParseItems.new(
      data: data,
      item_class: Wm3CelsiusBridge::Chiller
    ).call
  end

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

    it "parses all item data" do
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

    it "parses only valid item data" do
      expect(result.size).to eq(2)
    end
  end
end
