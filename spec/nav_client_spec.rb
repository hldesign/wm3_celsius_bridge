RSpec.describe Wm3CelsiusBridge::NavClient do
  describe "#get_customers", soap: true do
  	let(:response) { subject.get_customers }
	 	let(:customers) { response.data }
  	let(:error_message) { response.message }

    context "when request is good" do
	    before do
	      fixture = File.read("spec/fixtures/nav_client/customers.xml")
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
	      expect(customers.size).to eq(3)
	    end

	    it "fetches correct customer data" do
	      expect(customers.first[:no]).to eq("0000")
	      expect(customers.first[:name]).to eq("VÄXJÖ TRANSPORTKYLA AB ")
	      expect(customers.last[:no]).to eq("0002")
	      expect(customers.last[:address]).to eq("STREET")
	    end
	  end

    context "when request is bad" do
	    before do
	      soap_fault = File.read("spec/fixtures/nav_client/customers_missing_parameter.xml")
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
	      fixture = File.read("spec/fixtures/nav_client/customers_missing_data.xml")
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

  describe "#get_chillers", soap: true do
  	let(:response) { subject.get_chillers }
	 	let(:chillers) { response.data }
  	let(:error_message) { response.message }

		before do
			fixture = File.read("spec/fixtures/nav_client/chillers.xml")
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
			expect(chillers.size).to eq(3)
		end

		it "fetches correct chiller data" do
			chiller = chillers.first
			expect(chiller[:no]).to eq("10001")
			expect(chiller[:serial_no]).to eq("0045187")
			expect(chiller[:priority]).to eq("Medium")
			expect(chiller[:customer_no]).to eq("1337")
		end
  end
end
