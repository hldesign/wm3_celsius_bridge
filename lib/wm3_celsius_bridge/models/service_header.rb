# frozen_string_literal: true

# <complexType name="ServiceHeader">
#   <sequence>
#     <element minOccurs="1" maxOccurs="1" name="ExecutionWorkshopCustNo" type="string"/>
#     <element minOccurs="0" maxOccurs="1" name="YourReference" type="string"/>
#     <element minOccurs="0" maxOccurs="1" name="Description" type="string"/>
#     <element minOccurs="0" maxOccurs="1" name="ServiceOrderType" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="SerialNo" type="string"/>
#     <element minOccurs="0" maxOccurs="1" default="0001-01-01" name="ActionDate" type="date"/>
#     <element minOccurs="0" maxOccurs="1" name="RegNo" type="string"/>
#     <element minOccurs="0" maxOccurs="1" name="Model" type="string"/>
#   </sequence>
# </complexType>

module Wm3CelsiusBridge
  class ServiceHeader < Dry::Struct
    constructor_type :strict_with_defaults

    attribute :execution_workshop_cust_no, Types::MandatoryString.constrained(max_size: 20)
    attribute :serial_no, Types::MandatoryString.constrained(max_size: 20)
    attribute :your_reference, Types::OptionalString.constrained(max_size: 35)
    attribute :description, Types::OptionalString.constrained(max_size: 50)
    # INTERN, GARANTI, AVTAL?
    attribute :service_order_type, Types::OptionalString.constrained(max_size: 10)
    attribute :action_date, Types::OptionalDate
    attribute :reg_no, Types::OptionalString.constrained(max_size: 20)
    attribute :model, Types::OptionalString.constrained(max_size: 50)
  end
end
