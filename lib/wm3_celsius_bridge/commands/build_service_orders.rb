# frozen_string_literal: true

module Wm3CelsiusBridge
  class BuildServiceOrders
    def initialize(data:, reporter: NullReporter.new)
      @data = data
      @reporter = reporter
    end

    def call
      orders = data.map { |o| build_service_order(o) }.compact
      reporter.finish(message: "Built #{orders.size} NAV orders of #{data.size} WM3 orders.")
      orders
    end

    private

    attr_reader :data, :reporter

    def build_service_order(order)
      if order[:chiller].blank?
        reporter.error(
          message: "Missing chiller data for WM3 order '#{order[:id]}'",
          model: order,
        )
        return
      end

      if order[:order_items].blank?
        reporter.error(
          message: "Missing order items for WM3 order '#{order[:id]}'",
          model: order,
        )
        return
      end

      header = build_service_header(order)
      return if header.blank?

      item_line = build_service_item_line(order)
      return if item_line.blank?

      ServiceOrder.new(
        service_header: header,
        service_item_line: item_line
      )
    rescue StandardError => e
      reporter.error(
        message: "Could not build NAV order from WM3 order '#{order[:id]}'.",
        info: e.message,
        model: order,
      )
      return
    end

    def build_service_header(order)
        # attribute :execution_workshop_cust_no, Types::MandatoryString.constrained(max_size: 20)
        # attribute :serial_no, Types::MandatoryString.constrained(max_size: 20)
        # attribute :your_reference, Types::OptionalString.constrained(max_size: 35)
      # attribute :description, Types::OptionalString.constrained(max_size: 50)
      # # INTERN, GARANTI, AVTAL?
      # attribute :service_order_type, Types::OptionalString.constrained(max_size: 10)
        # attribute :action_date, Types::OptionalDate
        # attribute :reg_no, Types::OptionalString.constrained(max_size: 20)
        # attribute :model, Types::OptionalString.constrained(max_size: 50)

      header_attrs = {
        execution_workshop_cust_no: order[:customer_no],
        serial_no: order[:chiller_serial_no],
        your_reference: order[:ert_ordernr],
        action_date: order[:submitted_at],
        reg_no: order[:chiller][:reg_no],
        model: order[:chiller][:model],
      }

      ServiceHeader.new(header_attrs)
    rescue StandardError => e
      reporter.error(
        message: "Could not build NAV service header from WM3 order '#{order[:id]}'.",
        info: e.message,
        model: order,
      )
      return
    end

    def build_service_item_line(order)
      service_lines = order[:order_items].map { |item| build_service_line(item) }.compact

      if service_lines.empty?
        reporter.error(
          message: "Could not build any NAV service lines from WM3 order '#{order[:id]}'.",
          model: order,
        )
        return
      end

        # attribute :mileage, Types::OptionalFloat
      # attribute :runtime_total, Types::OptionalFloat
        # attribute :runtime_day, Types::OptionalFloat
        # attribute :runtime_night, Types::OptionalFloat
        # attribute :reg_no, Types::OptionalString
        # attribute :warranty, Types::Strict::Bool.optional.default(nil)
        # attribute :service_lines, Types.Array(ServiceLine).constrained(min_size: 1)

      item_line_attrs = {
        mileage: order[:meter_indication].to_f,
        runtime_day: order[:uptime_diesel].to_f,
        runtime_night: order[:uptime_night].to_f,
        reg_no: order[:chiller][:reg_no],
        warranty: order[:order_purpose] == 'warranty',

        service_lines: service_lines
      }

      ServiceItemLine.new(item_line_attrs)
    rescue StandardError => e
      reporter.error(
        message: "Could not build NAV service item line from WM3 order '#{order[:id]}'.",
        info: e.message,
        model: order,
      )
      return
    end

    def build_service_line(item)
        # attribute :no, Types::MandatoryString.constrained(max_size: 20)
        # attribute :quantity, Types::Strict::Int
        # attribute :line_amount, Types::Strict::Float
        # attribute :description, Types::MandatoryString.constrained(max_size: 100)
        # attribute :parts_or_time, Types::Strict::String.enum('Parts', 'Time')
      # attribute :unitof_measure, Types::OptionalString.constrained(max_size: 10)
      # attribute :location_code, Types::OptionalString.constrained(max_size: 10)

      if item[:item_type] == 'activity'
        no = 'V-9'
        desc = item[:sku]

      elsif item[:item_type] == 'additional'
        no = 'V-9'
        desc = item[:sku] + ' - ' + item[:name]

      else # Article
        no = item[:sku]
        desc = item[:name]
      end

      service_line_attrs = {
        no: no,
        quantity: item[:quantity].to_i,
        line_amount: item[:amount].to_f,
        description: desc,
        parts_or_time: 'Parts',
      }

      ServiceLine.new(service_line_attrs)
    rescue StandardError => e
      reporter.error(
        message: "Could not build NAV service line from WM3 order item '#{item[:id]}'.",
        info: e.message,
        model: item,
      )
      return
    end
  end
end
