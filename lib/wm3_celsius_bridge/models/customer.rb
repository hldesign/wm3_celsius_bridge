# frozen_string_literal: true

module Wm3CelsiusBridge
  # The Customer Class wraps the SOAP
  # response into something simpler.
  class Customer < Dry::Struct
    attribute :no, Types::NonBlankStrippedString
    attribute :name, Types::StrippedString
    attribute :address, Types::StrippedString
    attribute :post_code, Types::StrippedString
    attribute :city, Types::StrippedString
    attribute :phone_no, Types::Strict::Array.of(Types::StrippedString)
    attribute :fax_no, Types::StrippedString

    attribute :balance_lcy, Types::CustomFloat
    attribute :last_date_modified, Types::CustomDate

    attribute :copy_sellto_addrto_qte_from, Types::StrippedString

    attribute :gen_bus_posting_group, Types::Coercible::String
    attribute :vat_bus_posting_group, Types::Coercible::String
    attribute :customer_posting_group, Types::Coercible::String
    attribute :customer_price_group, Types::Coercible::String

    attribute :allow_line_disc, Types::Strict::Bool
    attribute :application_method, Types::Coercible::String

    attribute :payment_terms_code, Types::Coercible::String
    attribute :inder_terms_code, Types::Coercible::String
  end
end
