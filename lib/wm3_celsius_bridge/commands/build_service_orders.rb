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
      if order[:id].blank?
        reporter.error(
          message: "Missing order ID for WM3 order.",
          model: order,
        )
        return
      end

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
        id: order[:id],
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
      header_attrs = {
        execution_workshop_cust_no: order[:customer_no],
        serial_no: order[:chiller_serial_no],
        your_reference: order[:ert_ordernr],
        order_no: order[:order_no],
        order_date: (Date.strptime(order[:reparation_date], "%Y-%m-%d") rescue nil),
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

      text_service_lines = build_text_service_lines(order)

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
        service_lines: service_lines + text_service_lines
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
      if item[:item_type] == 'activity'
        type = 1 # Unconfirmed
        no = item[:sku]
        desc = item[:name]
        quantity = item[:item_quantity].to_i
        amount = item[:item_amount].to_f

      elsif item[:item_type] == 'additional'
        type = 1
        no = 'V-9'
        desc = item[:sku] + ' ' + item[:name]
        quantity = item[:quantity].to_i # From dynamic field
        amount = (quantity * item[:price].to_i).to_f # From dynamic field

      else # Article
        type = 1
        no = 'V-9'
        desc = item[:sku] + ' ' + item[:name]
        quantity = item[:item_quantity].to_i
        amount = item[:item_amount].to_f

      end

      service_line_attrs = {
        type: type,
        no: no,
        quantity: quantity,
        line_amount: amount,
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

    def build_text_service_lines(order)
      order
        .select { |k| [:reason, :diagnos, :correction].include?(k) }
        .map { |_, v| (v || '').scan(/.{1,50}/) }
        .flatten
        .map do |line|
          begin
            ServiceLine.new({
              type: 0, # 'Text' type
              description: line
            })
          rescue StandardError => e
            reporter.error(
              message: "Could not build NAV text service line from WM3 order '#{order[:id]}'.",
              info: e.message,
              model: item,
            )
          end
        end.compact
    end
  end
end
