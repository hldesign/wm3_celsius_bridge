# frozen_string_literal: true

require 'wm3_celsius_bridge/commands/parse_chillers'
require 'wm3_celsius_bridge/commands/import_chillers'
require 'wm3_celsius_bridge/commands/parse_customers'

module Wm3CelsiusBridge
  # SyncWorker starts a complete import of
  # data from NAV
  #
  # ==== Attributes
  #
  # * +client+ - A client to make requests to NAV.
  # * +store+ - Storage for parsed chillers.
  # * +limit+ - Max amount of chillers to import.
  #
  # ==== Examples
  #
  #   client = NavClient.new(debug: true)
  #   SyncWorker.new(client).call
  class SyncWorker
    attr_reader :client, :store, :limit

    def initialize(client:, store:, limit: 0)
      @client = client
      @store = store
      @limit = limit
    end

    def call
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

      chillers = ParseCustomers.new(resp.data).call

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

      chillers = ParseChillers.new(resp.data).call

      limited_chillers = limit > 0 ? chillers.take(limit) : chillers

      ImportChillers.new(
        chillers: limited_chillers,
        store: store
      ).call
    end
  end
end
