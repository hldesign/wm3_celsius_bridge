# frozen_string_literal: true

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
    logger = Wm3CelsiusBridge.logger
    client = NavClient.new(debug: debug)
    subdomain = Wm3CelsiusBridge.config.subdomain

    site = Site.where(subdomain: subdomain).first
    if site.nil?
      logger.fatal("Could not find site '#{subdomain}'.")
      return
    end

    store = site.store
    if store.nil?
      logger.fatal("Site '#{subdomain}' has no store.")
      return
    end

    SyncWorker.new(client: client, store: store).call
  end

  def self.logger
    @logger ||= CelsiusLogger.new(Logger.new(STDOUT))
  end

  def self.logger=(logger)
    @logger = CelsiusLogger.new(logger)
  end
end

require 'wm3_celsius_bridge/mocks' unless defined?(Rails)
