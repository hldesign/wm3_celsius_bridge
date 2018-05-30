# frozen_string_literal: true

# <complexType name="ServiceLedgerEntry">
#   <sequence>
#     <element minOccurs="1" maxOccurs="1" default="0" name="EntryNo" type="int"/>
#     <element minOccurs="1" maxOccurs="1" name="ServiceContractNo" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="DocumentType" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="DocumentNo" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ServContractAccGrCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" default="0" name="DocumentLineNo" type="int"/>
#     <element minOccurs="1" maxOccurs="1" name="MovedfromPrepaidAcc" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="PostingDate" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="AmountLCY" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="CustomerNo" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ShiptoCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ItemNoServiced" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="SerialNoServiced" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="UserID" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ContractInvoicePeriod" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="GlobalDimension1Code" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="GlobalDimension2Code" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ServiceItemNoServiced" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="VariantCodeServiced" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ContractGroupCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="Type" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="No" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="CostAmount" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="DiscountAmount" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="UnitCost" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="Quantity" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ChargedQty" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="UnitPrice" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="Discount" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ContractDiscAmount" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="BilltoCustomerNo" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="FaultReasonCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="Description" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ServiceOrderType" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ServiceOrderNo" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="JobNo" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="GenBusPostingGroup" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="GenProdPostingGroup" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="LocationCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="UnitofMeasureCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="WorkTypeCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="BinCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ResponsibilityCenter" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="VariantCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="EntryType" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="Open" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ServPriceAdjmtGrCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="ServicePriceGroupCode" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="Prepaid" type="string"/>
#     <element minOccurs="1" maxOccurs="1" default="0" name="ApplyUntilEntryNo" type="int"/>
#     <element minOccurs="1" maxOccurs="1" default="0" name="AppliestoEntryNo" type="int"/>
#     <element minOccurs="1" maxOccurs="1" name="Amount" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="JobTaskNo" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="JobLineType" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="JobPosted" type="string"/>
#     <element minOccurs="1" maxOccurs="1" default="0" name="DimensionSetID" type="int"/>
#     <element minOccurs="1" maxOccurs="1" name="Mileage" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="RuntimeTotal" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="RuntimeDay" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="RuntimeNight" type="string"/>
#     <element minOccurs="1" maxOccurs="1" name="MaintenaceType" type="string"/>
#   </sequence>
# </complexType>

module Wm3CelsiusBridge
  class ServiceLedgerEntry < Dry::Struct
    attribute :no, Types::OptionalString # "A-170211", ca 200 nil, ca 1400 uniq
    attribute :entry_no, Types::MandatoryString.constrained(max_size: 20) # "20041", uniq, counter
    attribute :serial_no_serviced, Types::NonBlankStrippedString # "C-RB650057", ca 1500 nil
    attribute :service_order_no, Types::NonBlankStrippedString # "S101205", ca 1200 nil
    attribute :customer_no, Types::NonBlankStrippedString # "1915",
    attribute :billto_customer_no, Types::NonBlankStrippedString # "1915",
    attribute :posting_date, Types::MandatoryCustomDate # "08/01/17",
    attribute :description, Types::StrippedString # "Mellanservice / Inspektion av kylaggregat",
    attribute :charged_qty, Types::Coercible::Float # "-1.5",
    attribute :mileage, Types::CustomFloat # "134,721.00",
    attribute :runtime_total, Types::CustomFloat # "37,066.00",
    attribute :runtime_day, Types::CustomFloat # "16,746.00",
    attribute :runtime_night, Types::CustomFloat # "4,689.00",
    attribute :unitof_measure_code, Types::OptionalString
  end
end
