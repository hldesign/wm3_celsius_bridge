require 'singleton'

#
# Configuration class for Wm3CelsiusBridge. This allows a
# configuration block to be used on an initializer.
#
# @example
#   Wm3CelsiusBridge.configure do |config|
#     config.user_name = ENV['NAV_USER_NAME']
#     config.user_domain = ENV['NAV_USER_DOMAIN']
#     config.password = ENV['NAV_PASSWORD']
#     config.endpoint = ENV['NAV_ENDPOINT']
#   end
#
module Wm3CelsiusBridge
  class Configuration

    include Singleton

    @@defaults = {
      user_name: '',
      user_domain: '',
      password: '',
      endpoint: ''
    }

    attr_accessor :user_name, :user_domain, :password, :endpoint

    def self.defaults
      @@defaults
    end

    def initialize
      @@defaults.each_pair{|k,v| self.send("#{k}=",v)}
    end
  end

  def self.config
    Configuration.instance
  end

  def self.configure
    yield config
  end
end
