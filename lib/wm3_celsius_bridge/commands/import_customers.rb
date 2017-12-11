# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ImportCustomers command imports parsed customers into WM3.
  class ImportCustomers
    attr_reader :customers, :store

    def initialize(customers:, store:)
      @customers = customers
      @store = store
    end

    def call
      imported = customers.map { |c| import_customer(c) }.compact
      Wm3CelsiusBridge.logger.info("Imported #{imported.size} of #{customers.size} customers.")
    end

    private

    def import_customer(customer)
      true
    end
  end
end
