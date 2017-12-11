# frozen_string_literal: true

require 'wm3_celsius_bridge/models/chiller'

module Wm3CelsiusBridge
  # The ParseChillers command parses chiller
  # data fetched from NAV.
  class ParseChillers
    attr_reader :data

    def initialize(data)
      @data = data || []
    end

    def call
      parsed_chillers = data.map { |c| parse_chiller(c) }.compact
      Wm3CelsiusBridge.logger.info("Parsed #{parsed_chillers.size} of #{data.size} chillers.")
      parsed_chillers
    end

    private

    def parse_chiller(data)
      Chiller.new(data)
    rescue StandardError => e
      msg = "Could not parse chiller (no=#{data[:no]}, serial_no=#{data[:serial_no]})"
      Wm3CelsiusBridge.logger.error(msg)
      Wm3CelsiusBridge.logger.error(e.message)
      return nil
    end
  end
end
