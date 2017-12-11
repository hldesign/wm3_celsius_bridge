# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ParseItems command parses data fetched from NAV.
  class ParseItems
    def initialize(data:, item_class:)
      @data = data || []
      @item_class = item_class
    end

    def call
      parsed_items = data.map { |c| parse_item(c) }.compact
      Wm3CelsiusBridge.logger.info("Parsed #{parsed_items.size} of #{data.size} #{item_class.name}.")
      parsed_items
    end

    private

    attr_reader :data, :item_class

    def parse_item(data)
      item_class.new(data)
    rescue StandardError => e
      msg = "Could not parse item (no=#{data[:no]})"
      Wm3CelsiusBridge.logger.error(msg)
      Wm3CelsiusBridge.logger.error(e.message)
      return nil
    end
  end
end
