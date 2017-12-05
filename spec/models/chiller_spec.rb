# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::Chiller do
  let(:chiller) { Wm3CelsiusBridge::Chiller.new(data) }

  context "with valid data" do
    let(:data) { YAML.load_file("spec/fixtures/chiller_valid_data.yml") }

    it "parses chiller dates" do
      expect(chiller.warranty_starting_date_labor).to be_a(Date)
      expect(chiller.warranty_ending_date_labor).to be_a(Date)
      expect(chiller.warranty_starting_date_parts).to be_a(Date)
      expect(chiller.warranty_ending_date_parts).to be_a(Date)
      expect(chiller.last_service_date).to be_nil
    end

    it "parses chiller floats" do
      expect(chiller.safety_pressure).to be_a(Float)
      expect(chiller.safety_pressure).to eq(1.23)
      expect(chiller.coolants_volume).to eq(1234.56)
    end

    it "parses chiller enums" do
      expect(chiller.priority).to eq("Medium")
    end
  end

  context "with missing float value" do
    let(:data) { YAML.load_file("spec/fixtures/chiller_missing_float_value.yml") }

    it "throws exception" do
      expect { chiller }.to raise_error(ArgumentError)
    end
  end

  context "with wrong enum value" do
    let(:data) { YAML.load_file("spec/fixtures/chiller_wrong_enum_value.yml") }

    it "throws exception" do
      expect { chiller }.to raise_error(Dry::Struct::Error)
    end
  end
end
