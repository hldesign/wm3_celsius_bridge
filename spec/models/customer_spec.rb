# frozen_string_literal: true

require "wm3_celsius_bridge/models/customer"

RSpec.describe Wm3CelsiusBridge::Customer do
  let(:customer) { described_class.new(data) }

  let(:data) do
    {
      :name => 'VAXJO TRANSPORTKYLA AB        ',
      :address => 'RENVÄGEN 17                   ',
      :post_code => '352 45',
      :city => 'VÄXJÖ                         ',
      :phone_no => '0470-48700                    ',
      :last_date_modified => '2016-06-14',
      :internal_cust => true,
  }.merge(customer_no_data)
  end

  let(:customer_no_data) { { :no => "0000" } }

  context "with valid data" do
    it "parses customer data" do
      expect { customer }.not_to raise_error
    end
  end

  context "with missing customer number" do
    let(:customer_no_data) { {} }

    it "throws exception" do
      expect { customer }.to raise_error(Dry::Struct::Error)
    end
  end
end
