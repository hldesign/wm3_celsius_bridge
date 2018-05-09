# frozen_string_literal: true

module Wm3CelsiusBridge
  class ServiceOrder < Dry::Struct
    include OmitBlankAttributes
    constructor_type :strict_with_defaults

    attribute :id, Types::Strict::Integer
    attribute :service_header, ServiceHeader
    attribute :service_item_line, ServiceItemLine
  end
end
