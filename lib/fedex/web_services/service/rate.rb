require 'bigdecimal'

module Fedex::WebServices
  module Service
    class Rate < Base

      def get_rates(service_type, rate_request_type, shipper, recipient, weight, &process_contents)
        request = GetRates.new(self,
          service_type,
          rate_request_type,
          shipper,
          recipient,
          weight
        )

        response = issue_request(request, &process_contents)
        return [ Rate.rate_for(response, rate_request_type), response ]
      end

      def service_id
        :crs
      end

      def self.rate_for(response, rate_request_type)
        details = response.rateReplyDetails.first.ratedShipmentDetails.select do |detail|
          detail.shipmentRateDetail.rateType == "PAYOR_#{rate_request_type}_PACKAGE"
        end

        details.inject(0) do |acc, detail|
          acc + BigDecimal.new(detail.shipmentRateDetail.totalNetCharge.amount)
        end
      end

      protected
        def port
          RatePortType.new('https://wsbeta.fedex.com:443/web-services')
        end
    end
  end
end