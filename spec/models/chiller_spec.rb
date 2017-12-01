RSpec.describe Wm3CelsiusBridge::Chiller do
  let(:data) { YAML.load_file("spec/fixtures/chiller_data.yml") }
  let(:chiller) { Wm3CelsiusBridge::Chiller.new(data) }

  describe "#new" do
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
end
