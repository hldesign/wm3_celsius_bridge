# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::ParseCustomers do
  let(:result) { Wm3CelsiusBridge::ParseCustomers.new(data).call }

  before do
    allow(Wm3CelsiusBridge::Customer).to receive(:new) do |arg|
      arg[:valid] ? arg : raise(ArgumentError.new('Invalid arg.'))
    end
  end

  context "with valid data" do
    let(:data) do
      [
        { no: "1", name: "Name 11", valid: true },
        { no: "2", name: "Name 22", valid: true },
        { no: "3", name: "Name 33", valid: true }
      ]
    end

    it "parses all customer data" do
      expect(result.size).to eq(data.size)
    end
  end

  context "with invalid data" do
    let(:data) do
      [
        { no: "1", name: "Name 11", valid: true },
        { no: "2", name: "Name 22", valid: false },
        { no: "3", name: "Name 33", valid: true }
      ]
    end

    it "parses only valid customer data" do
      expect(result.size).to eq(2)
    end
  end
end
