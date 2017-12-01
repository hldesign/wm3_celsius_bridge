module Wm3CelsiusBridge

  # The ImportChillers Class formats chiller
  # data from NAV and imports it into WM3.
  class ImportChillers
    attr_reader :chillers_data

    def initialize(chillers_data)
      @chillers_data = chillers_data
    end

    def call
      chillers_data.map { |c| build_chiller(c) }
    end

    private

    def build_chiller(data)
      Chiller.new(data)
    end
  end
end
