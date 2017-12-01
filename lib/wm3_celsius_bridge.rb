require "wm3_celsius_bridge/version"
require 'wm3_celsius_bridge/configuration'
require 'wm3_celsius_bridge/nav_client'
require 'wm3_celsius_bridge/sync_worker'

require 'wm3_celsius_bridge/models/types'
require 'wm3_celsius_bridge/models/chiller'

require 'wm3_celsius_bridge/railtie' if defined?(Rails)

# Module that sync data from NAV.
#
# ==== Examples
#
#   Wm3CelsiusBridge.sync
module Wm3CelsiusBridge
  def self.sync
    client = NavClient.new
    SyncWorker.new(client).call
  end
end
