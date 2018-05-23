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
      end || Types::Params::Date[*args]
    end
    MandatoryCustomDate = Types::Date.constructor do |*args|
      begin
        ::Date.strptime(*args, "%m/%d/%y")
      rescue ArgumentError, TypeError
      end || begin
        ::Date.strptime(*args, "%m/%d/%Y")
      rescue ArgumentError, TypeError
      end || ::Date.strptime(*args, "%Y-%m-%d")
    end

    # CustomFloat removes comma and space separators
    # before coercing into float. Ex:
    # "11,333.90" => "11333.90" => 11333.9
    CustomFloat = Types::Float.constructor do |arg|
      val = (arg || "").gsub(/[^0-9\.]/, '')
      Types::Coercible::Float[val]
    end

    # A ChillerNo must be at least five characters.
    ChillerNo = Types::Strict::String.constrained(min_size: 5)

    # A NonBlankStrippedString cannot be blank or contain only white space.
    NonBlankStrippedString = Types::StrippedString.constrained(min_size: 1)

    # ImportServiceOrder types
    MandatoryString = Types::Strict::String
    OptionalString = Types::Strict::String.optional.default('')
    OptionalDate = Types::Strict::Date.optional.default(nil)
    OptionalInt = Types::Strict::Integer.optional.default(nil)
    OptionalFloat = Strict::Float.optional.default(nil)
  end
end
