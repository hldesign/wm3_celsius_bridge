# frozen_string_literal: true

namespace :celsius do
  desc 'Sync data from NAV'
  task :sync, [:last_sync, :limit, :debug] => :environment do |t, args|
    debug = args.debug == 'true'
    limit = args.limit.to_i
    last_sync = args.last_sync.blank? ? Time.zone.today - 1 : args.last_sync

    report = Wm3CelsiusBridge.sync(last_sync: last_sync, limit: limit, debug: debug)

    puts report
  end
end
