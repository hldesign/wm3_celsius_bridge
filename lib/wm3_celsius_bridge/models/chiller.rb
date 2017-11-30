require 'ostruct'
#
# The Chiller Class wraps the SOAP
# response into something simpler.
#
module Wm3CelsiusBridge
  class Chiller < OpenStruct
    ATTRS = %i(
      serial_no
      reg_no
      model
      installation_date
      customer_no
      service_contracts
    )

    def self.build(hash)
      attrs = hash.select { |attr| ATTRS.include?(attr)}
      OpenStruct.new(attrs)
    end
  end
end


