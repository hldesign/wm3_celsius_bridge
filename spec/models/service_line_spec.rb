# frozen_string_literal: true

require "wm3_celsius_bridge/models/service_line"

RSpec.describe Wm3CelsiusBridge::ServiceLine do
  let(:service_line) { described_class.new(data) }

  let(:data) do
    {
      :type => 0,
      :description => "My description",
      :parts_or_time => "Parts",
      :line_discount_percent => 100,
    }
  end

  context "with valid data" do
    it "parses service line data" do
      expect { service_line }.not_to raise_error
    end

    it "#to_hash omits empty attributes" do
      expect(service_line.to_hash).to eq({
        :type=>0,
        :description=>"My description",
        :parts_or_time=>"Parts",
        :line_discount_percent=>100
      })
    end

    it "#to_h omits empty attributes" do
      expect(service_line.to_h).to eq({
        :type=>0,
        :description=>"My description",
        :parts_or_time=>"Parts",
        :line_discount_percent=>100
      })
    end
  end
end
