# frozen_string_literal: true

namespace :celsius do
  desc 'Sync data from NAV'
  task sync: :environment do
    Wm3CelsiusBridge.sync
  end
end
