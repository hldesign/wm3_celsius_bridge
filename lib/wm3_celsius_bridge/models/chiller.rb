# frozen_string_literal: true

module Wm3CelsiusBridge
  # The Chiller Class wraps the SOAP
  # response into something simpler.
  class Chiller < Dry::Struct
    # General
    attribute :no, Types::ChillerNo
    attribute :serial_no, Types::NonBlankStrippedString
    attribute :warranty_starting_date_parts, Types::CustomDate
    attribute :warranty_ending_date_parts, Types::CustomDate
    attribute :reg_no, Types::StrippedString

    # Customer
    attribute :customer_no, Types::NonBlankStrippedString

    # Details
    attribute :installation_date, Types::CustomDate

    # Properties
    attribute :model, Types::NonBlankStrippedString
    attribute :coolants_type, Types::StrippedString
    attribute :gwp, Types::CustomFloat
    attribute :coolants_volume, Types::CustomFloat
    attribute :safety_pressure, Types::CustomFloat
    attribute :low_pressure_guard, Types::CustomFloat
    attribute :high_pressure_guard, Types::CustomFloat
    attribute :co2_coefficient, Types::CustomFloat

    # History
    attribute :dateof_last_service, Types::CustomDate
    attribute :dateof_last_seepagecontrol, Types::CustomDate
    attribute :dateof_last_temp_control, Types::CustomDate
  end
end
