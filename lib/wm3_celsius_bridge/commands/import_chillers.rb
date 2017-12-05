# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ImportChillers command imports parsed chillers into WM3.
  class ImportChillers
    attr_reader :chillers

    def initialize(chillers = [])
      @chillers = chillers
    end

    def call
      imported = chillers.map { |c| import_chiller(c) }.compact
      Wm3CelsiusBridge.logger.info("Imported #{imported.size} of #{chillers.size} chillers.")
      imported
    end

    private

    def import_chiller(chiller)
      # TODO: import chiller
      chiller
    end
  end
end
