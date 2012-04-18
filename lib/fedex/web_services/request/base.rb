require 'time'

module Fedex::WebServices
  module Request
    class Base
      include Fedex::WebServices::Definitions

      def initialize(service)
        @service = service
      end

      def remote_method
        raise "remote_method must be implemented by subclasses of Service"
      end

      private
        def web_authentication_detail
          WebAuthenticationDetail.new.tap do |o|
            o.userCredential = WebAuthenticationCredential.new.tap do |o|
              o.key      = @service.credentials.key
              o.password = @service.credentials.password
            end
          end
        end

        def client_detail
          ClientDetail.new.tap do |o|
            o.accountNumber = @service.credentials.account_number
            o.meterNumber   = @service.credentials.meter_number
          end
        end

        def version
          VersionId.new.tap do |o|
            o.serviceId    = @service.service_id
            o.major        = 10
            o.intermediate = 0
            o.minor        = 0
          end
        end
    end
  end
end
# return
#
#
# ship_service = Fedex::WebServices::Service::Ship.new(creds)
# a = nil
# ship_service.delete_shipment('1234', 'GROUND') { |contents| a = contents }
#
# # req = FedExRequest.new(credentials).delete_shipment_request('794797411470', TrackingIdType::GROUND)
# req = FedExRequest.new(credentials).process_shipment
# ship_port = ShipPortType.new('https://wsbeta.fedex.com:443/web-services')
# ship_port.wiredump_dev = STDOUT
#
# begin
#   # response = ship_port.deleteShipment(req)
#   response = ship_port.processShipment(req)
#   check_response(response)
# rescue Exception => root_exception
#   begin
#     err = RuntimeError.new(root_exception.detail.fault.details.validationFailureDetail.message * ",")
#     err.set_backtrace([ "#{__FILE__}:#{__LINE__}", *root_exception.backtrace ])
#   rescue
#     raise root_exception.message
#   end
#
#   raise err
# end
