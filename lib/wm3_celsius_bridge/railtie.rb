# frozen_string_literal: true

module Wm3CelsiusBridge
  # Railtie for adding rake tasks
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "wm3_celsius_bridge/tasks/celsius.rake"
    end

    initializer "Rails logger" do
      Wm3CelsiusBridge.logger = Rails.logger
    end
  end
end
