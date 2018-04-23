# frozen_string_literal: true

module Wm3CelsiusBridge
  class CollectServiceOrders
    def initialize(store:, reporter: NullReporter.new)
      @store = store
      @reporter = reporter
    end

    def call
      collected_orders = filtered_orders.map { |o| order_attributes(o) }.compact
      reporter.finish(message: "Collected #{collected_orders.size} WM3 orders of #{filtered_orders.count} available.")
      collected_orders
    end

    private

    attr_reader :store, :reporter

    def order_attributes(order)
      order_attrs = {
        id: order.id,
        submitted_at: (Date.strptime(order.completed_at.to_s, "%Y-%m-%d") rescue nil),
        customer_no: order.customer.present? ? order.customer.number : nil,
        order_no: order.number,
      }.merge(order.dynamic_field_values
        .eager_load(:dynamic_field)
        .pluck('shop_dynamic_fields.name', 'value')
        .each_with_object({}) { |f, h| h[f[0].to_sym] = f[1] })

      serial = order_attrs[:chiller_serial_no]
      chiller = chiller_by_serial(serial)
      if chiller.nil?
        reporter.error(
          message: "Could not find Chiller '#{serial}' for WM3 order '#{order.id}'.",
          model: order,
        )
        return
      end

      order_attrs
        .tap { |attrs| attrs[:chiller] = chiller_attributes(chiller) }
        .merge(order_items: order.order_items.map { |item| item_attributes(item) })

    rescue StandardError => e
      reporter.error(
        message: "Could not collect data for WM3 order '#{order.id}'.",
        info: e.message
      )
      return nil
    end

    def chiller_attributes(chiller)
      chiller
        .product_attributes
        .each_with_object({}) { |attr, hash| hash[attr.type_name.to_sym] = attr.value_name }
    end

    def item_attributes(item)
      {
        id: item.id,
        sku: item.sku,
        name: item.name,
        price: item.price,
        amount: item.amount
      }.merge(item.dynamic_field_values
        .eager_load(:dynamic_field)
        .pluck('shop_dynamic_fields.name', 'value')
        .each_with_object({}) { |f, h| h[f[0].to_sym] = f[1] })
        .merge(quantity: item.quantity)
    end

    def chiller_by_serial(serial)
      store.products.includes(:product_attributes).where(skus: serial).first
    end

    def filtered_orders
      @filtered_orders ||= relation.where(state: 'certified_for_payment')
    end

    def relation
      store.orders.eager_load(:customer, order_items: { dynamic_field_values: :dynamic_field }, dynamic_field_values: :dynamic_field)
    end
  end
end
