# frozen_string_literal: true
require 'ostruct'

module Wm3CelsiusBridge
  # The ParseItems command parses data fetched from NAV.
  class ParseItems
    def initialize(data:, item_class:, reporter:)
      @data = data || []
      @item_class = item_class
      @reporter = reporter
    end

    def call
      parsed_items = data.map { |c| parse_item(c) }.compact
      reporter.finish(message: "Parsed #{parsed_items.size} of #{data.size} #{item_class.name}.")
      parsed_items
    end

    private

    attr_reader :data, :item_class, :reporter

    def parse_item(data)
      item_class.new(data)
    rescue StandardError => e
      reporter.error(
        message: "Could not parse item (no=#{data[:no]})",
        info: e.message,
        model: data,
      )
      return nil
    end
  end
end
