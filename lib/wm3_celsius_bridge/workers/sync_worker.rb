# frozen_string_literal: true

module Wm3CelsiusBridge
  # SyncWorker starts a complete import of
  # data from NAV
  #
  # ==== Attributes
  #
  # * +client+ - A client to request data from NAV.
  # * +store+ - Storage for parsed NAV items.
  # * +limit+ - Max amount of NAV items to import.
  #
  # ==== Examples
  #
  #   client = NavClient.new(debug: true)
  #   store = Shop::Store.first
  #
  #   SyncWorker.new(
  #     client: client,
  #     store: store,
  #     limit: 100
  #   ).call
  class SyncWorker
    attr_reader :client, :store, :limit

    def initialize(client:, store:, limit: 0)
      @client = client
      @store = store
      @limit = limit
    end

    def call
      # Note that import order matters.
      sync_customers
      sync_chillers
    end

    private

    def sync_customers
      resp = client.customers

      unless resp.ok?
        Wm3CelsiusBridge.logger.error(resp.message)
        return
      end

      customers = ParseItems.new(
        data: resp.data,
        item_class: Customer
      ).call

      limited_customers = limit > 0 ? customers.take(limit) : customers

      ImportCustomers.new(
        customers: limited_customers,
        store: store
      ).call
    end

    def sync_chillers
      resp = client.chillers

      unless resp.ok?
        Wm3CelsiusBridge.logger.error(resp.message)
        return
      end

      chillers = ParseItems.new(
        data: resp.data,
        item_class: Chillers
      ).call

      limited_chillers = limit > 0 ? chillers.take(limit) : chillers

      ImportChillers.new(
        chillers: limited_chillers,
        store: store
      ).call
    end
  end
end
