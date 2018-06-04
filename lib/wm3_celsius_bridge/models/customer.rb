# frozen_string_literal: true

module Wm3CelsiusBridge
  # The Customer Class wraps the SOAP
  # response into something simpler.
  class Customer < Dry::Struct
    # General
    attribute :no, Types::NonBlankStrippedString # Uniq, no blanks.
    attribute :name, Types::StrippedString
    attribute :address, Types::StrippedString
    attribute :post_code, Types::StrippedString
    attribute :city, Types::StrippedString

    # Communication
    attribute :phone_no, Types::StrippedString

    # Other
    attribute :last_date_modified, Types::CustomDate
    attribute :internal_cust, Types::Strict::Bool
  end
end
