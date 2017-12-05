# frozen_string_literal: true

require 'savon'
require 'ostruct'

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
    SOAP_TIMEOUT = 60

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
        convert_request_keys_to :none
        element_form_default :qualified
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
      dig_response(response, :contacts_result, :w_s_contacts, :contact)
    end

    def prices
      response = call(:Prices, wSPrices: {})
      dig_response(response, :prices_result, :w_s_prices)
    end

    def service_ledger_entries
      response = call(:ServiceLedgerEntries, wSServiceLedgerEntries: {})
      dig_response(response, :service_ledger_entries_result, :w_s_service_ledger_entries)
    end

    def parts_and_service_types
      response = call(:PartsAndServiceTypes, partsServiceTypes: {})
      dig_response(response, :parts_and_service_types_result, :w_s_service_ledger_entries)
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
        failure("Unexpected NAV response structure. Could find path #{path.inspect}")
      else
        success(data)
      end
    end
  end
end
