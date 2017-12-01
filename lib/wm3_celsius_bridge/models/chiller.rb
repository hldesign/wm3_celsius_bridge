module Wm3CelsiusBridge

  # The Chiller Class wraps the SOAP
  # response into something simpler.
  class Chiller < Dry::Struct
    attribute :no, Types::String
    attribute :serial_no, Types::String
    attribute :priority, Types::String
    attribute :customer_no, Types::String
    attribute :warranty_starting_date_labor, Types::CustomDate
    attribute :warranty_ending_date_labor, Types::CustomDate
    attribute :warranty_starting_date_parts, Types::CustomDate
    attribute :warranty_ending_date_parts, Types::CustomDate
    attribute :last_service_date, Types::CustomDate
    attribute :shipto_name, Types::String
    attribute :shipto_address, Types::String
    attribute :shipto_post_code, Types::String
    attribute :shipto_city, Types::String
    attribute :shipto_phone_no, Types::String
    attribute :reg_no, Types::String
    attribute :model, Types::String
    attribute :engine_no, Types::String
    attribute :compressor_no, Types::String
    attribute :coolants_type, Types::String
    attribute :coolants_volume, Types::Coercible::Float
    attribute :safety_pressure, Types::Coercible::Float
    attribute :low_pressure_guard, Types::Coercible::Float
    attribute :high_pressure_guard, Types::Coercible::Float
    attribute :interntnr, Types::String
    attribute :co2_coefficient, Types::String
    attribute :dateof_last_service, Types::CustomDate
    attribute :dateof_last_seepagecontrol, Types::CustomDate
    attribute :dateof_last_temp_control, Types::CustomDate
  end
end
