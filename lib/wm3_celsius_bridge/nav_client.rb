# frozen_string_literal: true

require 'savon'
require 'ostruct'
require 'date'

module Wm3CelsiusBridge
  # The NavClient Class retrieves data
  # from NAV through SOAP.
  #
  # ==== Attributes
  #
  # * +debug+ - Set debug mode to log SOAP requests.
  #
  # ==== Examples
  #
  #   NavClient.new.chillers
  class NavClient
    SOAP_TIMEOUT = 900

    attr_reader :client

    def initialize(debug: false)
      config = Wm3CelsiusBridge.config

      @client = Savon.client do
        ntlm [
          config.user_name,
          config.password,
          config.user_domain
        ]
        endpoint config.endpoint
        namespace_identifier :wsm
        namespace "urn:microsoft-dynamics-schemas/codeunit/WSManagement"
        namespaces("xmlns:x50" => "urn:microsoft-dynamics-nav/xmlports/x50004")
        convert_request_keys_to :none
        element_form_default :qualified
        open_timeout SOAP_TIMEOUT
        read_timeout SOAP_TIMEOUT
        logger Wm3CelsiusBridge.logger
        log true if debug
        log_level :debug if debug
        pretty_print_xml true if debug
      end
    end

    def chillers
      response = call(:Chillers, chiller: {})
      dig_response(response, :chillers_result, :chiller, :chiller)
    end

    def customers
      response = call(:Customers, customers: {})
      dig_response(response, :customers_result, :customers, :customer)
    end

    def resources
      response = call(:Resources, wSResources: {})
      dig_response(response, :resources_result, :w_s_resources, :resource)
    end

    def contacts
      response = call(:Contacts, wSContacts: {})
      dig_contacts_response(response, :contacts_result, :w_s_contacts, :contact_business_relation)
    end

    def prices
      response = call(:Prices, wSPrices: {})
      dig_response(response, :prices_result, :w_s_prices)
    end

    def service_ledger_entries
      response = call(:ServiceLedgerEntries, wSServiceLedgerEntries: {})
      dig_response(response, :service_ledger_entries_result, :w_s_service_ledger_entries)
    end

    def parts_and_service_types(modified_after: Time.zone.today - 1)
      filter = parts_and_service_type_filter(modified_after)
      response = call(:PartsAndServiceTypes, partsServiceTypes: filter )
      dig_parts_and_service_types_response(response, :parts_and_service_types_result, :parts_service_types)
    end

    private

    def call(operation, message = {})
      msg = message.merge(systemId: "run")

      begin
        Timeout.timeout(SOAP_TIMEOUT) do
          response = @client.call(operation, message: msg).body
          success(response)
        end
      rescue Timeout::Error => e
        failure("Timeout when calling NAV: #{e.message}")
      rescue Savon::SOAPFault,
             Savon::UnknownOperationError,
             Savon::HTTPError,
             Savon::InvalidResponseError => e
        failure("SOAP error when calling NAV: #{e.message}")
      rescue Errno::EADDRNOTAVAIL, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
        failure("Connection error when calling NAV: #{e.message}")
      end
    end

    def success(data)
      OpenStruct.new("ok?": true, data: data)
    end

    def failure(message)
      OpenStruct.new("ok?": false, message: message)
    end

    def dig_response(response, *path)
      return response unless response.ok?

      data = response.data.respond_to?(:dig) && response.data.dig(*path)
      if data.nil?
        failure("Unexpected NAV response structure. Could not find path #{path.inspect}")
      else
        success(data)
      end
    end

    def dig_contacts_response(contacts_response, *path)
      response = dig_response(contacts_response, *path)
      return response unless response.ok?

      data = response.data.map { |item| item.dig(:contacts, :contact) }.flatten(1)
      if data.nil?
        failure("Unexpected NAV response structure. Could not find path [:contacts, :contact]")
      else
        success(data)
      end
    end

    def dig_parts_and_service_types_response(response, *path)
      digged = dig_response(response, *path)

      return digged unless digged.ok?

      # Parts is nil when no filter matches was found.
      # Parts is a Hash when one match was found.
      # Parts is an Array otherwise.
      parts = digged.data[:part]

      parsed_parts = if parts.nil?
        []
      elsif parts.is_a?(Hash)
        [parts]
      else
        parts
      end

      success(parsed_parts)
    end

    def parts_and_service_type_filter(modified_after)
      return {} if modified_after.nil?

      {
        "x50:Filter" => {
          "x50:Filter_ModifiedDateAfter" => modified_after.to_s
        }
      }
    end
  end
end
