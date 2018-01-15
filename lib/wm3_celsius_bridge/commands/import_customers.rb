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

    def import_customer(c)
      group = find_or_create_customer_group(name: c.no)
      if group.new_record?
        Wm3CelsiusBridge.logger.error("Could not create customer group for customer #{c.no}")
        return
      end

      customer = find_or_build_customer(number: c.no)

      customer.customer_group = group
      customer.company = c.name
      customer.customer_type = :company

      customer.primary_account.verified = true
      customer.primary_account.phone = c.phone_no

      unless customer.save
        Wm3CelsiusBridge.logger.error("Could not create or update customer #{c.no}: #{customer.errors.full_messages}")
        Wm3CelsiusBridge.logger.error("Customer data: #{c.inspect}")
        return
      end

      address = customer.addresses.first_or_initialize.tap do |a|
        a.country = store.default_country if a.new_record?
        a.address1 = c.address
        a.zipcode = c.post_code
        a.city = c.city
        a.phone = c.phone_no
      end

      unless address.save
        Wm3CelsiusBridge.logger.error("Could not create or update address for customer #{c.no}: #{address.errors.full_messages}")
        Wm3CelsiusBridge.logger.error("Customer data: #{c.inspect}")
      end

      true
    end

    def find_or_create_customer_group(name:)
      store.customer_groups.where(name: name).first_or_create
    end

    def find_or_build_customer(number:)
      store.customers.where(number: number).first_or_initialize.tap do |c|
        if c.new_record?
          c.primary_account.skip_registration_message = true
          c.primary_account.password = SecureRandom.hex(10)
          c.primary_account.email = "customer-#{number}@example.com"
        end
      end
    end
  end
end
