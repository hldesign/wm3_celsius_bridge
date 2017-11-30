require 'wm3_celsius_bridge/commands/import_chillers'

module Wm3CelsiusBridge
  class SyncWorker
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def call
      import_chillers
    end

    private

    def import_chillers
      data = client.get_chillers
      ImportChillers.new(data).call
    end
  end
end
