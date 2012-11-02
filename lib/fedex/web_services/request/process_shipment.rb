module Fedex::WebServices
  module Request
    class ProcessShipment < Base

      def self.mps_requests(service, service_type, shipper, recipient,
          label_specification, package_weights)

        package_weights.map.with_index do |weight, index|
          requested_package_line_item = RequestedPackageLineItem.new.tap do |o|
            o.sequenceNumber = index + 1
            o.weight = weight
          end

          ProcessShipment.new(
            service,
            service_type,
            shipper,
            recipient,
            label_specification,
            package_weights.size,
            [ requested_package_line_item ]
          )
        end
      end

      def initialize(service, service_type, shipper, recipient,
          label_specification, package_count, requested_package_line_items)

        super(service)

        @service_type = service_type
        @shipper = shipper
        @recipient = recipient
        @label_specification = label_specification
        @package_count = package_count
        @requested_package_line_items = requested_package_line_items
      end

      def remote_method
        :processShipment
      end

      def contents
        ProcessShipmentRequest.new.tap do |o|
          o.webAuthenticationDetail = web_authentication_detail
          o.version                 = version
          o.clientDetail            = client_detail

          o.requestedShipment = RequestedShipment.new.tap do |o|
            o.shipTimestamp = Time.now.iso8601
            o.dropoffType   = DropoffType::REGULAR_PICKUP
            o.serviceType   = @service_type
            o.packagingType = PackagingType::YOUR_PACKAGING

            o.shipper   = @shipper
            o.recipient = @recipient

            o.shippingChargesPayment = Payment.new.tap do |o|
              o.paymentType = PaymentType::SENDER
              o.payor = Payor.new.tap do |o|
                o.responsibleParty = @shipper.clone.tap do |o|
                  o.accountNumber = @service.credentials.account_number
                end
              end
            end

            o.labelSpecification = @label_specification

            o.rateRequestTypes = [ RateRequestType::LIST ]

            o.requestedPackageLineItems = @requested_package_line_items
            o.packageCount = @package_count
          end
        end
      end
    end
  end
end