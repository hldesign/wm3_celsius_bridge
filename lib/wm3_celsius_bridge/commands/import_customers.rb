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

      cust.dynamic_fields = { 'internal_customer' => { value: customer.internal_cust.to_s } }
      unless cust.save
        reporter.error(
          message: "Could not add dynamic fields to customer #{customer.no}",
          model: customer,
          info: cust.errors.full_messages,
        )
        return
      end

      create_customer_address(cust, customer)
      create_customer_discount_lists(customer)

      true
    rescue StandardError => e
      reporter.error(
        message: "Could not import customer (no=#{customer.no})",
        info: e.message
      )
      return nil
    end

    def create_customer_discount_lists(customer)
      jour_list_name = "contract_jour_discount_list_customer_#{customer.no}"
      no_jour_list_name = "contract_no_jour_discount_list_customer_#{customer.no}"

      list = store.discount_lists.where(name: jour_list_name).first_or_initialize
      unless list.save
        reporter.warning(
          message: "Could not create customer discount list '#{jour_list_name}' for customer #{customer.no}",
          model: customer,
          info: list.errors.full_messages,
        )
      end

      list = store.discount_lists.where(name: no_jour_list_name).first_or_initialize
      unless list.save
        reporter.warning(
          message: "Could not create customer discount list '#{no_jour_list_name}' for customer #{customer.no}",
          model: customer,
          info: list.errors.full_messages,
        )
      end
    end

    def create_customer_address(customer, customer_data)
      address = customer.addresses.first_or_initialize.tap do |a|
        a.country = store.default_country if a.new_record?
        a.address1 = customer_data.address
        a.zipcode = customer_data.post_code
        a.city = customer_data.city
        a.phone = customer_data.phone_no
      end

      unless address.save
        reporter.warning(
          message: "Could not create or update address for customer #{customer_data.no}",
          model: customer_data,
          info: address.errors.full_messages,
        )
      end
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
