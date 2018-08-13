# frozen_string_literal: true

namespace :celsius do
  namespace :sync do
    desc 'Sync all data from NAV'
    task :all, [:last_sync, :limit, :debug] => :environment do |t, args|
      debug = args.debug == 'true'
      limit = args.limit.to_i
      last_sync = args.last_sync.blank? ? Time.zone.today - 1 : args.last_sync

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

    desc 'Sync customers from NAV'
    task :customers, [:limit, :debug] => :environment do |t, args|
      debug = args.debug == 'true'
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

    desc 'Sync chillers from NAV'
    task :chillers, [:limit, :debug] => :environment do |t, args|
      debug = args.debug == 'true'
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

    desc 'Sync articles from NAV'
    task :articles, [:last_sync, :limit, :debug] => :environment do |t, args|
      debug = args.debug == 'true'
      limit = args.limit.to_i
      last_sync = args.last_sync.blank? ? Time.zone.today - 1 : args.last_sync

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

    desc 'Sync service ledger entries from NAV'
    task :service_ledger, [:last_sync, :limit, :debug] => :environment do |t, args|
      debug = args.debug == 'true'
      limit = args.limit.to_i
      last_sync = args.last_sync.blank? ? Time.zone.today - 1 : args.last_sync

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

    desc 'Export service orders to NAV'
    task :service_orders, [:debug] => :environment do |t, args|
      debug = args.debug == 'true'

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
