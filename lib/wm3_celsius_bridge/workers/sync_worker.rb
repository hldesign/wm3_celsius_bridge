# frozen_string_literal: true

require 'wm3_celsius_bridge/commands/parse_chillers'
require 'wm3_celsius_bridge/commands/import_chillers'

module Wm3CelsiusBridge
  # SyncWorker starts a complete import of
  # data from NAV
  #
  # ==== Attributes
  #
  # * +client+ - A client to make requests to NAV.
  #
  # ==== Examples
  #
  #   client = NavClient.new(debug: true)
  #   SyncWorker.new(client).call
  class SyncWorker
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def call
      sync_chillers
    end

    private

    def sync_chillers
      resp = client.chillers

      unless resp.ok?
        Wm3CelsiusBridge.logger.error(resp.message)
        return
      end

      chillers = ParseChillers.new(resp.data).call

      ImportChillers.new(chillers).call
    end
  end
end
