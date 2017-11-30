module Wm3CelsiusBridge
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "wm3_celsius_bridge/tasks/celsius.rake"
    end
  end
end
