module Fedex::WebServices
  module Request
    class GetRates < Base

      def initialize(service, service_type, rate_request_type, shipper, recipient, weight)

        super(service)

        @service_type = service_type
        @shipper = shipper
        @recipient = recipient
        @rate_request_type = rate_request_type
        @requested_package_line_items = [
          RequestedPackageLineItem.new.tap do |o|
            o.groupPackageCount = 1
            o.sequenceNumber = 1
            o.weight = weight
          end
        ]
      end

      def remote_method
        :getRates
      end

      def contents
        RateRequest.new.tap do |o|
          o.webAuthenticationDetail = web_authentication_detail
          o.version                 = version
          o.clientDetail            = client_detail

          o.requestedShipment = RequestedShipment.new.tap do |o|
            o.shipTimestamp = Time.now.iso8601
            o.serviceType   = @service_type
            o.packagingType = PackagingType::YOUR_PACKAGING

            o.shipper   = @shipper
            o.recipient = @recipient

            o.shippingChargesPayment = Payment.new.tap do |o|
              o.paymentType = PaymentType::SENDER
              o.payor = Payor.new.tap do |o|
                o.accountNumber = @service.credentials.account_number
              end
            end

            o.rateRequestTypes = [ @rate_request_type ]

            o.packageCount = @requested_package_line_items.size
            o.requestedPackageLineItems = @requested_package_line_items
          end
        end
      end
    end
  end
end