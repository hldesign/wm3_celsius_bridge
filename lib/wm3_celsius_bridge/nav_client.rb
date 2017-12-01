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
  #   NavClient.new.get_chillers
  class NavClient
    SOAP_TIMEOUT = 60

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
        logger Wm3CelsiusBridge.logger.unwrap
        if debug
          log true
          log_level :debug
          pretty_print_xml true
        end
      end
    end

    def get_chillers
      response = call(:Chillers, { chiller: {} })
      dig_response(response, :chillers_result, :chiller, :chiller)
    end

    def get_customers
      response = call(:Customers, { customers: {} })
      dig_response(response, :customers_result, :customers, :customer)
    end

    def get_resources
      response = call(:Resources, { wSResources: {} })
      dig_response(response, :resources_result, :w_s_resources, :resource)
    end

    def get_contacts
      response = call(:Contacts, { wSContacts: {} })
      dig_response(response, :contacts_result, :w_s_contacts, :contact)
    end

    def get_prices
      response = call(:Prices, { wSPrices: {} })
      dig_response(response, :prices_result, :w_s_prices)
    end

    def get_service_ledger_entries
      response = call(:ServiceLedgerEntries, { wSServiceLedgerEntries: {} })
      dig_response(response, :service_ledger_entries_result, :w_s_service_ledger_entries)
    end

    def get_parts_and_service_types
      response = call(:PartsAndServiceTypes, { partsServiceTypes: {} })
      dig_response(response, :parts_and_service_types_result, :w_s_service_ledger_entries)
    end

    def client
      @client
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
      rescue Savon::SOAPFault, Savon::UnknownOperationError, Savon::HTTPError, Savon::InvalidResponseError => e
        failure("SOAP error when calling NAV: #{e.message}")
      rescue Errno::EADDRNOTAVAIL, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
        failure("Connection error when calling NAV: #{e.message}")
      end
    end

    def success(data)
      OpenStruct.new({ "ok?": true, data: data })
    end

    def failure(message)
      OpenStruct.new({ "ok?": false, message: message })
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
