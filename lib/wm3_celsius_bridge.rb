# frozen_string_literal: true

require "wm3_celsius_bridge/version"
require 'wm3_celsius_bridge/configuration'
require 'wm3_celsius_bridge/ext/hash_extensions'

require 'wm3_celsius_bridge/celsius_logger'
require 'wm3_celsius_bridge/nav_client'
require 'wm3_celsius_bridge/workers/sync_worker'

require 'wm3_celsius_bridge/commands/event_reporter'
require 'wm3_celsius_bridge/commands/null_reporter'
require 'wm3_celsius_bridge/commands/product_importer'
require 'wm3_celsius_bridge/commands/uniq_checker'
require 'wm3_celsius_bridge/commands/parse_items'
require 'wm3_celsius_bridge/commands/import_chillers'
require 'wm3_celsius_bridge/commands/import_customers'
require 'wm3_celsius_bridge/commands/import_articles'
require 'wm3_celsius_bridge/commands/import_service_ledger_entries'
require 'wm3_celsius_bridge/commands/collect_service_orders'
require 'wm3_celsius_bridge/commands/build_service_orders'
require 'wm3_celsius_bridge/commands/export_service_orders'

require 'wm3_celsius_bridge/models/ext/omit_blank_attributes'
require 'wm3_celsius_bridge/models/types'
require 'wm3_celsius_bridge/models/chiller'
require 'wm3_celsius_bridge/models/customer'
require 'wm3_celsius_bridge/models/article'
require 'wm3_celsius_bridge/models/service_line'
require 'wm3_celsius_bridge/models/service_item_line'
require 'wm3_celsius_bridge/models/service_header'
require 'wm3_celsius_bridge/models/service_order'
require 'wm3_celsius_bridge/models/service_ledger_entry'

require 'wm3_celsius_bridge/railtie' if defined?(Rails)

# Module that sync data from NAV.
#
# ==== Attributes
#
# * +debug+ - Debug logging.
# * +limit+ - Max amount of chillers to import.
#
# ==== Examples
#
#   Wm3CelsiusBridge.sync(
#     debug: true,
#     limit: 1000,
#     last_sync: '2018-01-01',
#     enabled: {
#       chillers: true
#     }
#   )
module Wm3CelsiusBridge
  def self.sync(
    debug: false,
    limit: 0,
    last_sync: Time.zone.today - 1,
    enabled: {})

    logger = Wm3CelsiusBridge.logger
    client = NavClient.new(debug: debug)
    subdomain = Wm3CelsiusBridge.config.subdomain

    enabled_syncs = {
      customers: false,
      chillers: false,
      articles: false,
      service_ledger: false,
      orders: false,
    }.merge(enabled)

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

    report = SyncWorker.new(
      client: client,
      store: store,
      limit: limit,
      last_sync: last_sync,
      enabled_syncs: enabled_syncs
    ).call

    logger.info("Printing sync report.\n\n#{report}")

    report
  end

  def self.logger
    @logger ||= CelsiusLogger.new(Logger.new(STDOUT))
  end

  def self.logger=(logger)
    @logger = CelsiusLogger.new(logger)
  end
end

require 'wm3_celsius_bridge/mocks' unless defined?(Rails)
