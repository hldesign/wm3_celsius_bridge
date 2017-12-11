# frozen_string_literal: true

require 'wm3_celsius_bridge/models/customer'

module Wm3CelsiusBridge
  # The ParseCustomers command parses customer
  # data fetched from NAV.
  class ParseCustomers
    attr_reader :data

    def initialize(data)
      @data = data || []
    end

    def call
      parsed_customers = data.map { |c| parse_customer(c) }.compact
      Wm3CelsiusBridge.logger.info("Parsed #{parsed_customers.size} of #{data.size} customers.")
      parsed_customers
    end

    private

    def parse_customer(data)
      Customer.new(data)
    rescue StandardError => e
      msg = "Could not parse customer (no=#{data[:no]}, name=#{data[:name]})"
      Wm3CelsiusBridge.logger.error(msg)
      Wm3CelsiusBridge.logger.error(e.message)
      return nil
    end
  end
end
