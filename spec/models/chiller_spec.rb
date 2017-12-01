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
      expect(chiller.coolants_volume).to eq(1.23)
    end
  end

  context "with invalid data" do
    let(:data) { YAML.load_file("spec/fixtures/chiller_invalid_data.yml") }

    it "raises error" do
      expect{chiller}.to raise_error(ArgumentError)
    end
  end
end
