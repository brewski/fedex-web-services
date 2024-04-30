module FedexWebServices
  class Api
    include FedexWebServices::Soap

    class ServiceException < RuntimeError
      attr_accessor :details
    end

    Credentials = Struct.new(*%i(account_number meter_number key password environment))

    attr_reader :wiredump

    def initialize(credentials)
      @credentials = credentials
      @wiredump = ""
    end

    def process_shipments(requests)
      port = Ship::ShipPortType.new(service_url)
      first_response = nil

      requests.map.with_index do |request, ndx|
        if (ndx == 0)
          first_response = issue_request(port, request)
        else
          request.for_master_tracking_number!(
            first_response.contents.completedShipmentDetail.masterTrackingId.trackingNumber
          )
          issue_request(port, request)
        end
      end
    end

    def delete_shipment(request)
      issue_request(Ship::ShipPortType.new(service_url), request)
    end

    def close_smart_post(request)
      issue_request(Close::ClosePortType.new(service_url), request)
    end

    def service_url
      @service_url ||= (@credentials.environment.to_sym == :production) ?
          'https://ws.fedex.com/web-services' :
          'https://wsbeta.fedex.com/web-services'
    end

    private
      def issue_request(port, request)
        port.wiredump_dev = StringIO.new(request_wiredump = "")
        request.issue_request(port, @credentials).tap do |response|
          if (response.errors.any?)
            raise response.errors.map(&:message) * ". "
          end
        end
      rescue Exception => root_exception
        err = ServiceException.new(root_exception.message)
        err.details = root_exception.detail.fault.details.validationFailureDetail.message rescue nil
        raise err
      ensure
        @wiredump << request_wiredump if (request_wiredump)
      end
  end
end