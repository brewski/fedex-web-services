module Fedex::WebServices
  module Request
    class DeleteShipment < Base
      attr_accessor :tracking_id

      def initialize(service, tracking_id)
        super(service)
        @tracking_id = tracking_id
      end

      def remote_method
        :deleteShipment
      end

      def contents
        DeleteShipmentRequest.new.tap do |o|
          o.webAuthenticationDetail = web_authentication_detail
          o.version                 = version
          o.clientDetail            = client_detail
          o.deletionControl         = DeletionControlType::DELETE_ALL_PACKAGES

          o.trackingId = @tracking_id
        end
      end
    end
  end
end