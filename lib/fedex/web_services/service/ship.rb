require 'bigdecimal'
require 'base64'

module Fedex::WebServices
  module Service
    class Ship < Base

      def service_id
        :ship
      end

      def service_version
        12
      end

      def process_shipment(service_type, shipper, recipient, label_specification, package_weights)
        requests = ProcessShipment.mps_requests(
            self, service_type, shipper, recipient, label_specification, package_weights)

        first_response = nil
        responses = requests.map.with_index do |request, ndx|
          if (ndx == 0)
            first_response = issue_request(request) do |request_contents|
              yield(request_contents, ndx + 1) if (block_given?)
            end
          else
            issue_request(request) do |request_contents|
              request_contents.requestedShipment.masterTrackingId = TrackingId.new.tap do |ti|
                ti.trackingNumber = Ship::tracking_number_for(first_response)
              end

              yield(request_contents, ndx + 1) if (block_given?)
            end
          end
        end

        responses.map do |response|
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
      rescue
        raise "Unable to extract rate information from response"
      end

      protected
        def port
          ShipPortType.new(service_url)
        end
    end
  end
end