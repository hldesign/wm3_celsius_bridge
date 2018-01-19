# frozen_string_literal: true

# <complexType name="ServiceItemLine">
#   <sequence>
#     <element minOccurs="0" maxOccurs="1" default="0" name="Mileage" type="decimal"/>
#     <element minOccurs="0" maxOccurs="1" default="0" name="RuntimeTotal" type="decimal"/>
#     <element minOccurs="0" maxOccurs="1" default="0" name="RuntimeDay" type="decimal"/>
#     <element minOccurs="0" maxOccurs="1" default="0" name="RuntimeNight" type="decimal"/>
#     <element minOccurs="0" maxOccurs="1" name="RegNo" type="string"/>
#     <element minOccurs="0" maxOccurs="1" default="false" name="Warranty" type="boolean"/>
#     <element minOccurs="1" maxOccurs="1" name="ServiceLines" type="tns:ServiceLines"/>
#   </sequence>
# </complexType>

module Wm3CelsiusBridge
  class ServiceItemLine < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :mileage, Types::OptionalFloat
    attribute :runtime_total, Types::OptionalFloat
    attribute :runtime_day, Types::OptionalFloat
    attribute :runtime_night, Types::OptionalFloat
    attribute :reg_no, Types::OptionalString
    attribute :warranty, Types::Strict::Bool.optional.default(nil)
    attribute :service_lines, Types.Array(ServiceLine).constrained(min_size: 1)
  end
end
