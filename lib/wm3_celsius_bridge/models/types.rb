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
  end
end


