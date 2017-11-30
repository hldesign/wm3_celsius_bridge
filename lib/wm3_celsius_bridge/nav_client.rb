require 'savon'
require 'ostruct'

#
# The NavClient Class retrieves data
# from NAV through SOAP.
#
module Wm3CelsiusBridge
  class NavClient
    SOAP_TIMEOUT = 30

    def initialize
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
        logger Rails.logger if defined?(Rails)
        log true
        # log_level :debug
        pretty_print_xml true
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

    # <Contacts_Result xmlns="urn:microsoft-dynamics-schemas/codeunit/WSManagement">
    #   <wSContacts>
    #     <ContactBusinessRelation xmlns="urn:microsoft-dynamics-nav/xmlports/x50006" ContactNo="K10001">
    #       <Contacts>
    #         <Contact>
    #           <No>K10001</No>
    #           <Name>Kyl &amp; Frysexpressen           </Name>
    #           <SearchName>KYL &amp; FRYSEXPRESSEN</SearchName>
    #         </Contact>
    #         <Contact>
    #           <No>K10001</No>
    #           <Name>Kyl &amp; Frysexpressen           </Name>
    #           <SearchName>KYL &amp; FRYSEXPRESSEN</SearchName>
    #         </Contact>
    #       </Contacts>
    #     </ContactBusinessRelation>
    #   </wSContacts>
    #  </Contacts_Result>
    def get_contacts
      response = call(:Contacts, { wSContacts: {} })
      dig_response(response, :contacts_result, :w_s_contacts, :contact)
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
        failure(e.message)
      rescue Savon::SOAPFault => e
        failure(e.message)
      rescue Savon::UnknownOperationError, Savon::HTTPError, Savon::InvalidResponseError, Errno::EADDRNOTAVAIL, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
        failure(e.message)
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
        failure("Could not dig response path #{path.inspect}")
      else
        success(data)
      end
    end
  end
end
