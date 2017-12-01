require "wm3_celsius_bridge/version"
require 'wm3_celsius_bridge/configuration'

require 'wm3_celsius_bridge/celsius_logger'
require 'wm3_celsius_bridge/nav_client'
require 'wm3_celsius_bridge/workers/sync_worker'

require 'wm3_celsius_bridge/railtie' if defined?(Rails)

# Module that sync data from NAV.
#
# ==== Examples
#
#   Wm3CelsiusBridge.sync
module Wm3CelsiusBridge
  def self.sync(debug: false)
    client = NavClient.new(debug: debug)
    SyncWorker.new(client).call
  end

  def self.logger
    @@logger ||= CelsiusLogger.new(Logger.new(STDOUT))
  end

  def self.logger=(logger)
    @@logger = CelsiusLogger.new(logger)
  end
end
