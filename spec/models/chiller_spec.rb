# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::Chiller do
  let(:chiller) { described_class.new(data) }

  let(:data) do
    {
      :serial_no => "0045187",
      :description => "Frigoblock FK 13",
      :status => "Installed",
      :priority => "Medium",
      :customer_no => "1337",
      :unitof_measure_code => "ST",
      :sales_unit_price => "0.00",
      :sales_unit_cost => "0.00",
      :warranty_starting_date_labor => "2013-06-21",
      :warranty_ending_date_labor => "13-07-22",
      :warranty_starting_date_parts => "08/23/2013",
      :warranty_ending_date_parts => "08/24/13",
      :warranty_parts => "0",
      :warranty_labor => "0",
      :response_time_hours => "0",
      :default_contract_value => "0.00",
      :default_contract_discount => "0",
      :noof_active_contracts => "0",
      :no_series => "SERV-ARTIK",
      :name => "MT FJÄRR AB                   ",
      :address => "Gärdesv. 13                   ",
      :post_code => "342 50",
      :city => "VISLANDA                      ",
      :contact => "Mikael Svanbring              ",
      :phone_no => "0472-71776                    ",
      :usage_cost => "0.00",
      :usage_amount => "0.00",
      :invoiced_amount => "0.00",
      :total_quantity => "0",
      :total_qty_invoiced => "0",
      :resources_used => "0.00",
      :parts_used => "0.00",
      :cost_used => "0.00",
      :comment => "No",
      :service_item_components => "No",
      :contract_cost => "0.00",
      :default_contract_cost => "0.00",
      :prepaid_amount => "0.00",
      :service_contracts => "No",
      :total_qty_consumed => "0",
      :sales_serv_shpt_line_no => "0",
      :shipment_type => "Sales",
      :reg_no => "abc123",
      :model => "FRIGOBLOCK FK 13",
      :gwp => "0.00",
      :coolants_volume => "1, 234.56",
      :low_pressure_guard => "0.00",
      :high_pressure_guard => "0.00",
      :co2_coefficient => "0.00",
  }.merge(float_data).merge(chiller_no_data)
  end

  let(:float_data) { { :safety_pressure => "1.23" } }
  let(:chiller_no_data) { { :no => "10001" } }

  context "with valid data" do
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
    let(:float_data) { {} }

    it "throws exception" do
      expect { chiller }.to raise_error(Dry::Struct::Error)
    end
  end

  context "with wrong chiller no" do
    let(:chiller_no_data) { {} }

    it "throws exception" do
      expect { chiller }.to raise_error(Dry::Struct::Error)
    end
  end
end
