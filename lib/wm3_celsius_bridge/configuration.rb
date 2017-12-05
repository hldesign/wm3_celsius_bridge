# frozen_string_literal: true

require 'singleton'

module Wm3CelsiusBridge
  # Configuration class for Wm3CelsiusBridge. This allows a
  # configuration block to be used on an initializer.
  #
  # ==== Examples
  #
  #   Wm3CelsiusBridge.configure do |config|
  #     config.user_name = ENV['NAV_USER_NAME']
  #     config.user_domain = ENV['NAV_USER_DOMAIN']
  #     config.password = ENV['NAV_PASSWORD']
  #     config.endpoint = ENV['NAV_ENDPOINT']
  #     config.subdomain = "celsius" # default
  #   end
  class Configuration
    include Singleton

    @@defaults = {
      user_name: '',
      user_domain: '',
      password: '',
      endpoint: '',
      subdomain: 'celsius'
    }

    attr_accessor :user_name, :user_domain, :password, :endpoint, :subdomain

    def self.defaults
      @@defaults
    end

    def initialize
      @@defaults.each_pair { |key, val| send("#{key}=", val) }
    end
  end

  def self.config
    Configuration.instance
  end

  def self.configure
    yield config
  end
end
