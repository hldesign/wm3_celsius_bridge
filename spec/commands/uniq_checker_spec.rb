# frozen_string_literal: true

RSpec.describe Wm3CelsiusBridge::UniqChecker do
  let(:result) do
    Wm3CelsiusBridge::UniqChecker.new(
      models: models,
      prop_names: prop_names,
      reporter: Wm3CelsiusBridge::EventReporter.new(title: 'test'),
    ).call
  end

  let(:prop_names) { [:id, :serial_no] }

  context "with unique data" do
    let(:models) do
      [
        { id: "1", serial_no: "11", name: "model1" },
        { id: "2", serial_no: "22", name: "model2" },
        { id: "3", serial_no: "33", name: "model3" }
      ]
    end

    it "finds no duplicates" do
      expect(result).to eq({})
    end
  end

  context "with duplicate id" do
    let(:models) do
      [
        { id: "1", serial_no: "11", name: "model1" },
        { id: "2", serial_no: "22", name: "model2" },
        { id: "1", serial_no: "33", name: "model3" }
      ]
    end

    it "finds one duplicate" do
      expect(result).to eq({
        id: {
          "1" => [
            { id: "1", serial_no: "11", name: "model1" },
            { id: "1", serial_no: "33", name: "model3" }
          ]
        }
      })
    end
  end

  context "with duplicate serial_no" do
    let(:models) do
      [
        { id: "1", serial_no: "11", name: "model1" },
        { id: "2", serial_no: "11", name: "model2" },
        { id: "3", serial_no: "33", name: "model3" }
      ]
    end

    it "finds one duplicate" do
      expect(result).to eq({
        serial_no: {
          "11" => [
            { id: "1", serial_no: "11", name: "model1" },
            { id: "2", serial_no: "11", name: "model2" }
          ]
        }
      })
    end
  end

  context "with duplicate id and serial_no" do
    let(:models) do
      [
        { id: "1", serial_no: "11", name: "model1" },
        { id: "1", serial_no: "22", name: "model2" },
        { id: "3", serial_no: "22", name: "model3" }
      ]
    end

    it "finds two duplicates" do
      expect(result).to eq({
        id: {
          "1" => [
            { id: "1", serial_no: "11", name: "model1" },
            { id: "1", serial_no: "22", name: "model2" }
          ]
        },
        serial_no: {
          "22" => [
            { id: "1", serial_no: "22", name: "model2" },
            { id: "3", serial_no: "22", name: "model3" }
          ]
        }
      })
    end
  end
end
