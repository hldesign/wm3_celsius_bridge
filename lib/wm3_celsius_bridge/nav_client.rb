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

    using HashExtensions
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
        namespaces({
          "xmlns:x50004" => "urn:microsoft-dynamics-nav/xmlports/x50004",
          "xmlns:x50009" => "urn:microsoft-dynamics-nav/xmlports/x50009",
          "xmlns:x50010" => "urn:microsoft-dynamics-nav/xmlports/x50010"
        })
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
      dig_response(response, :prices_result, :w_s_prices, :sales_price)
    end

    def service_ledger_entries(posting_date: Date.today - 1)
      filter = service_ledger_entries_filter(posting_date)
      response = call(:ServiceLedgerEntries, wSServiceLedgerEntries: filter)
      dig_response(response, :service_ledger_entries_result, :w_s_service_ledger_entries, :service_ledger_entry)
    end

    def parts_and_service_types(modified_after: Date.today - 1)
      filter = parts_and_service_type_filter(modified_after)
      response = call(:PartsAndServiceTypes, partsServiceTypes: filter )
      dig_response(response, :parts_and_service_types_result, :parts_service_types, :part)
    end

    def import_service_order(service_order)
      payload = service_order_payload(service_order)
      response = call(:ImportServiceOrder, wSServiceOrder: payload)
      dig_response(response, :import_service_order_result, :return_value)
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

      last_path = path.pop

      data = response.data.respond_to?(:dig) && response.data.dig(*path)
      return failure("Unexpected NAV response structure. Could not find path #{path.inspect}") if data.nil?

      # When using filter:
      # Result is nil when no filter matches was found.
      # Result is a Hash when one match was found.
      # Result is an Array otherwise.
      result = data.dig(last_path)

      parsed_result = if result.nil?
        []
      elsif result.is_a?(Hash)
        [result]
      else
        result
      end

      success(parsed_result)
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

    def service_order_payload(service_order)
      payload = service_order.to_hash
      payload.delete(:id)
      service_lines = payload[:service_item_line][:service_lines]
      payload[:service_item_line][:service_lines] = { service_line: service_lines }

      payload.pascalcase_keys.prefix_keys('x50010:')
    end


    def parts_and_service_type_filter(modified_after)
      return {} if modified_after.nil?
      date = modified_after.is_a?(Date) ? modified_after : Date.parse(modified_after)

      {
        "x50004:Filter" => {
          "x50004:Filter_ModifiedDateAfter" => date.strftime('%Y-%m-%d')
        }
      }
    end

    def service_ledger_entries_filter(posting_date)
      return {} if posting_date.nil?

      date = posting_date.is_a?(Date) ? posting_date : Date.parse(posting_date)

      # Filter parameter only accepts US formatted dates.
      {
        "x50009:Filter" => {
          "x50009:Filter_PostingDate" => date.strftime('%D')
        }
      }
    end
  end
end
