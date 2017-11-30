require 'wm3_celsius_bridge/models/chiller'

#
# The ImportChillers Class formats chiller
# data from NAV and imports it into WM3.
#
module Wm3CelsiusBridge
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
      Chiller.build(data)
    end
  end
end
