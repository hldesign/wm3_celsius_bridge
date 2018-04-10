# frozen_string_literal: true
require 'ostruct'

module Wm3CelsiusBridge
  # The ImportCustomers command imports parsed customers into WM3.
  class ImportCustomers
    def initialize(customers:, store:, reporter:)
      @customers = customers
      @store = store
      @reporter = reporter
    end

    def call
      group = find_or_build_customer_group(name: 'Slutkunder')
      unless group.save
        reporter.error(
          message: "Could not save customer group #{group.name}",
          info: group.errors.full_messages,
        )
        return false
      end

      imported = customers.map do |customer|
        import_customer(customer: customer, group: group)
      end.compact

      reporter.finish(message: "Imported #{imported.size} of #{customers.size} customers.")
    end

    private

    attr_reader :customers, :store, :reporter

    def import_customer(customer:, group:)
      cust = find_or_build_customer(number: customer.no)

      cust.customer_group = group
      cust.company = customer.name
      cust.customer_type = :company

      cust.primary_account.verified = true
      cust.primary_account.phone = customer.phone_no

      unless cust.save
        reporter.error(
          message: "Could not create or update customer #{customer.no}",
          model: customer,
          info: cust.errors.full_messages,
        )
        return
      end

      address = cust.addresses.first_or_initialize.tap do |a|
        a.country = store.default_country if a.new_record?
        a.address1 = customer.address
        a.zipcode = customer.post_code
        a.city = customer.city
        a.phone = customer.phone_no
      end

      unless address.save
        reporter.error(
          message: "Could not create or update address for customer #{customer.no}",
          model: customer,
          info: address.errors.full_messages,
        )
      end

      true
    rescue StandardError => e
      reporter.error(
        message: "Could not import customer (no=#{customer.no})",
        info: e.message
      )
      return nil
    end

    def find_or_build_customer_group(name:)
      store.customer_groups.where(name: name).first_or_initialize.tap do |g|
        g.name = name
      end
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
