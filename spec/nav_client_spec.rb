# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::NavClient do
  let(:data) { response.data }
  let(:error_message) { response.message }

  describe "#customers", soap: true do
    let(:response) { subject.customers }

    context "when request is good" do
      before do
        fixture = File.read("spec/fixtures/soap_responses/customers_success.xml")
        msg = { customers: {}, systemId: "run" }
        savon.expects(:Customers).with(message: msg).returns(fixture)
      end

      it "successfully requests customers" do
        expect(response).to be_ok
      end

      it "returns no error message" do
        expect(error_message).to be_blank
      end

      it "fetches customer list" do
        expect(data.size).to eq(3)
      end

      it "fetches correct customer data" do
        expect(data.first[:no]).to eq("0000")
        expect(data.first[:name]).to eq("VAXJO TRANSPORTKYLA AB ")
        expect(data.last[:no]).to eq("0002")
        expect(data.last[:address]).to eq("STREET")
      end
    end

    context "when request is bad" do
      before do
        soap_fault = File.read("spec/fixtures/soap_responses/customers_missing_parameter.xml")
        response = { code: 500, headers: {}, body: soap_fault }
        msg = { customers: {}, systemId: "run" }
        savon.expects(:Customers).with(message: msg).returns(response)
      end

      it "fails to request customers" do
        expect(response).to_not be_ok
      end

      it "returns an error message" do
        expect(error_message).to_not be_blank
      end
    end

    context "when response data is bad" do
      before do
        fixture = File.read("spec/fixtures/soap_responses/customers_missing_data.xml")
        msg = { customers: {}, systemId: "run" }
        savon.expects(:Customers).with(message: msg).returns(fixture)
      end

      it "fails to request customers" do
        expect(response).to_not be_ok
      end

      it "returns an error message" do
        expect(error_message).to_not be_blank
      end
    end
  end

  describe "#chillers", soap: true do
    let(:response) { subject.chillers }

    before do
      fixture = File.read("spec/fixtures/soap_responses/chillers_success.xml")
      msg = { chiller: {}, systemId: "run" }
      savon.expects(:Chillers).with(message: msg).returns(fixture)
    end

    it "successfully requests chillers" do
      expect(response).to be_ok
    end

    it "returns no error message" do
      expect(error_message).to be_blank
    end

    it "fetches list of chillers" do
      expect(data.size).to eq(3)
    end

    it "fetches correct chiller data" do
      chiller = data.first
      expect(chiller[:no]).to eq("10001")
      expect(chiller[:serial_no]).to eq("0045187")
      expect(chiller[:priority]).to eq("Medium")
      expect(chiller[:customer_no]).to eq("1337")
    end
  end

  describe "#parts_and_service_types", soap: true do
    let(:response) { subject.parts_and_service_types(modified_after: "2017-12-14") }
    let(:fixture) { File.read("spec/fixtures/soap_responses/parts_and_service_types_3_elements_success.xml") }

    before do
      msg = {
        partsServiceTypes: {
          "x50:Filter" => {
            "x50:Filter_ModifiedDateAfter" => "2017-12-14"
          }
        },
        systemId: "run"
      }

      savon.expects(:PartsAndServiceTypes).with(message: msg).returns(fixture)
    end

    it "successfully requests data" do
      expect(response).to be_ok
    end

    it "returns no error message" do
      expect(error_message).to be_blank
    end

    it "fetches list of parts and service types" do
      expect(data.size).to eq(2)
    end

    it "fetches correct data" do
      type = data.first
      expect(type[:no]).to eq("M-ACA201A032L")
      expect(type[:description]).to eq("CR2323LL-L")
    end

    context "reply contains one element" do
      let(:fixture) { File.read("spec/fixtures/soap_responses/parts_and_service_types_1_element_success.xml") }

      it "fetches list of parts and service types" do
        expect(data.size).to eq(1)
      end
    end

    context "reply contains no elements" do
      let(:fixture) { File.read("spec/fixtures/soap_responses/parts_and_service_types_no_elements_success.xml") }

      it "fetches list of parts and service types" do
        expect(data).to eq([])
      end
    end
  end
end
