# frozen_string_literal: true

module Wm3CelsiusBridge
  class ServiceOrder < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :id, Types::Strict::Int
    attribute :service_header, ServiceHeader
    attribute :service_item_line, ServiceItemLine
  end
end
