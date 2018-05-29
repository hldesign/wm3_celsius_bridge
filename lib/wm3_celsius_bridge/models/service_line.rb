# frozen_string_literal: true

# <complexType name="ServiceLine">
#   <sequence>
#     <element minOccurs="1" maxOccurs="1" name="No" type="string"/>
#     <element minOccurs="1" maxOccurs="1" default="0" name="Quantity" type="decimal"/>
#     <element minOccurs="1" maxOccurs="1" default="0" name="LineAmount" type="decimal"/>
#     <element minOccurs="1" maxOccurs="1" name="Description" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="PartsOrTime" type="string"/>
#     <element minOccurs="0" maxOccurs="1" name="UnitofMeasure" type="string"/>
#     <element minOccurs="0" maxOccurs="1" name="LocationCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="LineDiscountPercent" type="decimal"/>
#   </sequence>
# </complexType>

module Wm3CelsiusBridge
  class ServiceLine < Dry::Struct
    include OmitBlankAttributes
    constructor_type :strict_with_defaults

    attribute :type, Types::Strict::Integer # Item type
    attribute :no, Types::OptionalString.constrained(max_size: 20)
    attribute :quantity, Types::OptionalInt
    attribute :line_amount, Types::OptionalFloat
    attribute :description, Types::MandatoryString.constrained(max_size: 100)
    attribute :parts_or_time, Types::Strict::String.enum('Parts', 'Time').optional.default(nil)
    attribute :unitof_measure, Types::OptionalString.constrained(max_size: 10)
    attribute :location_code, Types::OptionalString.constrained(max_size: 10)
    attribute :line_discount_percent, Types::Strict::Integer
  end
end
