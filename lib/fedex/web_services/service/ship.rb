require 'bigdecimal'
require 'base64'

module Fedex::WebServices
  module Service
    class Ship < Base

      def service_id
        :ship
      end

      def process_shipment(service_type, shipper, recipient,
          label_specification, package_weights, &process_contents)

        curry_process_contents_callback = ->(request_number) do
          return ->(request_contents) do
            process_contents.call(request_contents, request_number) if (process_contents)
          end
        end

        requests = ProcessShipment.mps_requests(self,
          service_type,
          shipper,
          recipient,
          label_specification,
          package_weights
        )

        first, rest = requests.first, requests[1..-1]

        first_response = issue_request(first, &curry_process_contents_callback.call(1))

        rest_responses = rest.map.with_index do |request, index|
          issue_request(request) do |request_contents|
            request_contents.requestedShipment.masterTrackingId = TrackingId.new.tap do |o|
              o.trackingNumber = Ship::tracking_number_for(first_response)
            end

            curry_process_contents_callback.call(index + 2).call(request_contents)
          end
        end

        [ first_response, *rest_responses ].map do |response|
          [
            self.class.tracking_number_for(response),
            self.class.label_for(response),
            self.class.package_rate_for(response),
            response
          ]
        end
      end

      def delete_shipment(*args, &process_contents)
        issue_request(DeleteShipment.new(self, *args), &process_contents)
      end

      def self.label_for(response)
        label = response.completedShipmentDetail.completedPackageDetails.first.label
        Base64.decode64(label.parts.map { |p| Base64.decode64(p.image) } * "")
      end

      def self.tracking_number_for(response)
        response.completedShipmentDetail.completedPackageDetails[0].trackingIds[0].trackingNumber
      rescue
        raise "Unable to extract tracking number from response"
      end

      def self.package_rate_for(response)
        response.completedShipmentDetail.completedPackageDetails.first.packageRating.
            packageRateDetails.inject(0) do |acc, rate|
              rate.rateType == ReturnedRateType::PAYOR_ACCOUNT_PACKAGE ?
                  acc + BigDecimal.new(rate.netCharge.amount) :
                  acc
            end
      end

      protected
        def port
          ShipPortType.new('https://wsbeta.fedex.com:443/web-services')
        end
    end
  end
end