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
        enabled: {
          customers: true,
          chillers: true,
          articles: true,
          service_ledger: true,
          orders: true
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
        enabled: { customers: true }
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
        enabled: { chillers: true }
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
        enabled: { articles: true }
      )

      puts report
    end

    desc 'Sync service ledger from NAV'
    task :service_ledger, [:last_sync, :limit, :debug] => :environment do |t, args|
      debug = args.debug == 'true'
      limit = args.limit.to_i
      last_sync = args.last_sync.blank? ? Time.zone.today - 1 : args.last_sync

      report = Wm3CelsiusBridge.sync(
        last_sync: last_sync,
        limit: limit,
        debug: debug,
        enabled: { service_ledger: true }
      )

      puts report
    end

    desc 'Export service orders to NAV'
    task :service_orders, [:debug] => :environment do |t, args|
      debug = args.debug == 'true'

      report = Wm3CelsiusBridge.sync(
        debug: debug,
        enabled: { orders: true }
      )

      puts report
    end
  end
end
