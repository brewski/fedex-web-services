require 'time'

require 'fedex_web_services/response'

module FedexWebServices
  class Request
    attr_reader :contents

    def soap_module
      raise "soap_module must be implemented by subclasses of Request::Base"
    end

    def remote_method
      raise "remote_method must be implemented by subclasses of Request::Base"
    end

    def service_id
      raise "service_id must be implemented by subclasses of Request::Base"
    end

    def version
      raise "version must be implemented by subclasses of Request::Base"
    end

    def issue_request(port, credentials)
      Response.new(port.send(remote_method, request_contents(credentials)))
    end

    protected
      def request_contents(credentials)
        mod = self.soap_module
        contents = self.contents.dup

        contents.webAuthenticationDetail =
            mod::WebAuthenticationDetail.new.tap do |wad|
              wad.userCredential = mod::WebAuthenticationCredential.new.tap do |wac|
                wac.key      = credentials.key
                wac.password = credentials.password
              end
            end

        contents.clientDetail = mod::ClientDetail.new.tap do |cd|
          cd.accountNumber = credentials.account_number
          cd.meterNumber   = credentials.meter_number
        end

        contents.version = mod::VersionId.new.tap do |vi|
          vi.serviceId    = service_id
          vi.major        = version
          vi.intermediate = 0
          vi.minor        = 0
        end

        contents
      end
  end
end
