# frozen_string_literal: true

namespace :celsius do
  namespace :sync do
    desc "Sync all data from NAV"
    task :all, %i[last_sync limit debug] => :environment do |_t, args|
      debug = args.debug == "true"
      limit = args.limit.to_i
      last_sync = (args.last_sync.presence || (Date.today - 1))

      report = Wm3CelsiusBridge.sync(
        last_sync: last_sync,
        limit: limit,
        debug: debug,
        sync_configs: {
          customers: {
            enabled: true,
            include_ids: []
          },
          chillers: {
            enabled: true
          },
          articles: {
            enabled: true
          },
          service_ledger: {
            enabled: true
          },
          orders: {
            enabled: true
          }
        }
      )

      puts report
    end

    desc "Sync customers from NAV"
    task :customers, %i[limit debug] => :environment do |_t, args|
      debug = args.debug == "true"
      limit = args.limit.to_i

      report = Wm3CelsiusBridge.sync(
        limit: limit,
        debug: debug,
        sync_configs: {
          customers: {
            enabled: true,
            include_ids: []
          }
        }
      )

      puts report
    end

    desc "Sync chillers from NAV"
    task :chillers, %i[limit debug] => :environment do |_t, args|
      debug = args.debug == "true"
      limit = args.limit.to_i

      report = Wm3CelsiusBridge.sync(
        limit: limit,
        debug: debug,
        sync_configs: {
          chillers: {
            enabled: true
          }
        }
      )

      puts report
    end

    desc "Sync articles from NAV"
    task :articles, %i[last_sync limit debug] => :environment do |_t, args|
      debug = args.debug == "true"
      limit = args.limit.to_i
      last_sync = (args.last_sync.presence || (Date.today - 1))

      report = Wm3CelsiusBridge.sync(
        last_sync: last_sync,
        limit: limit,
        debug: debug,
        sync_configs: {
          articles: {
            enabled: true
          }
        }
      )

      puts report
    end

    desc "Sync service ledger entries from NAV"
    task :service_ledger, %i[last_sync limit debug] => :environment do |_t, args|
      debug = args.debug == "true"
      limit = args.limit.to_i
      last_sync = (args.last_sync.presence || (Date.today - 1))

      report = Wm3CelsiusBridge.sync(
        last_sync: last_sync,
        limit: limit,
        debug: debug,
        sync_configs: {
          service_ledger: {
            enabled: true
          }
        }
      )

      puts report
    end

    desc "Export service orders to NAV"
    task :service_orders, [:debug] => :environment do |_t, args|
      debug = args.debug == "true"

      report = Wm3CelsiusBridge.sync(
        debug: debug,
        sync_configs: {
          orders: {
            enabled: true
          }
        }
      )

      puts report
    end
  end
end
