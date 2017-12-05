# frozen_string_literal: true

require 'dry-struct'

module Wm3CelsiusBridge
  # The Types module defines data types
  # used when parsing data from NAV.
  module Types
    include ::Dry::Types.module

    # StrippedString strips whitespace from data
    StrippedString = Types::String.constructor { |*args| String(*args).strip }

    # CustomDate parses US date formats in
    # addition to formats supported by Date.parse
    CustomDate = Types::Date.constructor do |*args|
      begin
        ::Date.strptime(*args, "%m/%d/%y")
      rescue ArgumentError, TypeError
      end || begin
        ::Date.strptime(*args, "%m/%d/%Y")
      rescue ArgumentError, TypeError
      end || Types::Form::Date[*args]
    end

    # CustomFloat removes comma and space separators
    # before coercing into float. Ex:
    # "11,333.90" => "11333.90" => 11333.9
    CustomFloat = Types::Float.constructor do |arg|
      val = (arg || "").gsub(/[^0-9\.]/, '')
      Types::Coercible::Float[val]
    end

    Priorities = Types::Strict::String.enum('Low', 'Medium', 'High')
  end
end
