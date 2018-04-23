# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::BuildServiceOrders do
  let(:result) do
    Wm3CelsiusBridge::BuildServiceOrders.new(
      data: data,
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
        {
          "id": 62163,
          "submitted_at": Date.parse('2018-04-01'),
          "order_no": "O12345678",
          "customer_no": "0001",
          "ert_ordernr": "ert-order-nr",
          "reparation_date": "2018-04-01",
          "uptime_diesel": "12",
          "order_purpose": "warranty",
          "jour": "true",
          "meter_indication": "1000",
          "uptime_night": "34",
          "reason": "<string>",
          "diagnos": "<text>",
          "correction": "<text>",
          "order_comment": "<text>",
          "chiller_serial_no": "CH-10022",
          "correct_owner": "true",
          "correct_license": "true",
          "correct_license_custom": "<string>",
          "chiller": {
            "low_pressure_guard": "0.0",
            "no": "10022",
            "gwp": "14119.0",
            "customer_no": "1474",
            "installation_date": "2010-12-29",
            "dateof_last_seepagecontrol": "2012-06-11",
            "dateof_last_service": "2012-06-11",
            "warranty_ending_date_parts": "2012-12-29",
            "high_pressure_guard": "32.0",
            "safety_pressure": "35.0",
            "coolants_volume": "3.6",
            "co2_coefficient": "50828.4",
            "reg_no": "JLB 003",
            "serial_no": "M-077700028BL",
            "model": "MITSUBISHI TNW 7 EA",
            "coolants_type": "R404A"
          },
          "order_items": [
            {
              "id": 77873,
              "sku": "M-PSA011H011",
              "name": "LABEL,CAUTI",
              "price": "0.0",
              "amount": "0.0",
              "item_type": "article",
              "quantity": 2
            },
            {
              "id": 77875,
              "sku": "M-851029",
              "name": "Motorvärmare 220 Volt TU100/TU85/TFV",
              "price": "0.0",
              "amount": "0.0",
              "item_type": "article",
              "quantity": 2
            },
            {
              "id": 77874,
              "sku": "SP-A01",
              "name": "Refrigerant recovery",
              "price": "0.0",
              "amount": "0.0",
              "comment": "a comment 2",
              "item_type": "activity",
              "hours": "0.5",
              "quantity": 2
            },
            {
              "id": 77876,
              "sku": "custom SKU 15",
              "name": "custom name 11",
              "price": "23",
              "amount": "0.0",
              "item_type": "additional",
              "quantity": 1
            }
          ]
        }
      ]
    end

    it "builds service orders" do
      expect(result.size).to eq(data.size)

      service_order = result.first
      service_header = service_order.service_header
      service_item_line = service_order.service_item_line
      service_lines = service_item_line.service_lines
      wm3_order = data.first

      expect(service_header.execution_workshop_cust_no).to eq(wm3_order[:customer_no])
      expect(service_item_line.reg_no).to eq(wm3_order[:chiller][:reg_no])

      # ServiceLines contains one entry per order item plus (at least)
      # one entry per text fields 'reason', 'diagnos' and 'correction'.
      expect(service_lines.size).to eq(wm3_order[:order_items].size + 3)
    end
  end
end
