# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::Chiller do
  let(:chiller) { described_class.new(data) }

  context "with valid data" do
    let(:data) { YAML.load_file("spec/fixtures/chiller_valid_data.yml") }

    it "parses chiller dates" do
      expect(chiller.warranty_starting_date_parts).to be_a(Date)
      expect(chiller.warranty_ending_date_parts).to be_a(Date)
      expect(chiller.dateof_last_service).to be_nil
    end

    it "parses chiller floats" do
      expect(chiller.safety_pressure).to be_a(Float)
      expect(chiller.safety_pressure).to eq(1.23)
      expect(chiller.coolants_volume).to eq(1234.56)
    end

    it "parses chiller no" do
      expect(chiller.no).to eq("10001")
    end
  end

  context "with missing float value" do
    let(:data) { YAML.load_file("spec/fixtures/chiller_missing_float_value.yml") }

    it "throws exception" do
      expect { chiller }.to raise_error(Dry::Struct::Error)
    end
  end

  context "with wrong chiller no" do
    let(:data) { YAML.load_file("spec/fixtures/chiller_wrong_chiller_no.yml") }

    it "throws exception" do
      expect { chiller }.to raise_error(Dry::Struct::Error)
    end
  end
end
