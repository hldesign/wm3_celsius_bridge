# frozen_string_literal: true

module Wm3CelsiusBridge
  class ExportServiceOrders

    def initialize(store:, client:, orders:, reporter: NullReporter.new)
      @store = store
      @client = client
      @orders = orders
      @reporter = reporter
    end

    def call
      exported = orders.map { |order| export_order(order) }.compact
      reporter.finish(message: "Exported #{exported.size} of #{orders.size} orders.")
    end

    private

    attr_reader :store, :client, :orders, :reporter

    def export_order(order)
      resp = client.import_service_order(order)

      if resp.ok?
        mark_order_sucess(order.id, resp.data)
        return true
      end

      reporter.error(
        message: "Failure when calling NAV for WM3 order '#{order.id}'.",
        info: resp.message,
        model: order,
      )

      mark_order_failure(order.id)

      return nil
    rescue StandardError => e
      reporter.error(
        message: "Could not export order '#{order.id}'.",
        info: e.message,
        model: order
      )
      return nil
    end

    def mark_order_sucess(order_id, nav_order_id)
      store.orders.where(id: order_id).update_all(
        state: 'nav_registration_success',
        state_updated_at: DateTime.now,
        number_two: nav_order_id
      )
    end

    def mark_order_failure(order_id)
      store.orders.where(id: order_id).update_all(
        state: 'nav_registration_failure',
        state_updated_at: DateTime.now
      )
    end
  end
end
