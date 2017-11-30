require "wm3_celsius_bridge/version"
require 'wm3_celsius_bridge/configuration'
require 'wm3_celsius_bridge/nav_client'
require 'wm3_celsius_bridge/sync_worker'

#
# Module that sync data from NAV.
#
# @example Sync data
#   CelsiusBridge.sync
#
module Wm3CelsiusBridge
  def self.sync
    client = NavClient.new
    SyncWorker.new(client).call
  end
end
