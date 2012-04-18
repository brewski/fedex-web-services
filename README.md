## Creating the FedEx Web Services class definitions
### Rails
This gem includes a rake task to generate the class definitions and create an initializer to load them if you are using it from within a rails application.  Simply save the FedEx wsdl files to a directory (lib/fedex/web_services/wsdl in this example) and run:

    $ WSDL_DIR=lib/fedex/web_services/wsdl rake fedex:generate_definitions
    Added lib/fedex/web_services/definitions/
    Added config/initializers/fedex.rb

### Manual creation
You can also manually generate the class files.  To to this, run the following command:

    require 'fedex'
    Fedex::WebServices::Definitions.generate_definitions('lib', *Dir.glob('path/to/wsdls/*.wsdl'))

This will create the directory lib/fedex/web_services/definitions/ with the FedEx Web Services class definitions in it.

## Examples
### Getting shipping rates

    require 'fedex'
    # config/initializers/fedex.rb handles this if you are in a Rails app and have run the rake task above
    # Fedex::WebServices::Definitions.load_definitions('lib')

    include Fedex::WebServices
    include Fedex::WebServices::Definitions

    credentials = Service::Base::Credentials.new(
      "ACCOUNT#",
      "METER#",
      "AUTH_KEY",
      "SECURITY_CODE"
    )

    # prod_credentials = Service::Base::Credentials.new(
    #   "ACCOUNT#",
    #   "METER#",
    #   "AUTH_KEY",
    #   "SECURITY_CODE",
    #   :production
    # )

    shipper = Party.new.tap do |o|
      o.address = Address.new.tap do |o|
        o.postalCode  = "93401"
        o.countryCode = "US"
        o.residential = true
      end
    end

    recipient = Party.new.tap do |o|
      o.address = Address.new.tap do |o|
        o.postalCode  = "95630"
        o.countryCode = "US"
        o.residential = true
      end
    end

    weight = Weight.new.tap do |o|
      o.units = "LB"
      o.value = 42.42
    end

    rate_service = Service::Rate.new(credentials)
    rate, response = rate_service.get_rates(
      ServiceType::FEDEX_2_DAY, RateRequestType::LIST, shipper, recipient, weight
    )
    puts "List rate for 42.42 lbs, 2 day from 93401 to 07541: #{rate.to_f}"


### Creating a shipment with multiple packages

    shipper = Party.new.tap do |o|
      o.contact = Contact.new.tap do |o|
        o.personName  = "Joe Shmoe"
        o.phoneNumber = "(123) 456 789"
      end
      o.address = Address.new.tap do |o|
        o.streetLines         = [ "123 4th St" ]
        o.city                = "San Luis Obispo"
        o.stateOrProvinceCode = "CA"
        o.postalCode          = "93401"
        o.countryCode         = "US"
        o.residential         = true
      end
    end

    recipient = Party.new.tap do |o|
      o.contact = Contact.new.tap do |o|
        o.personName  = "Joe Shmoe"
        o.phoneNumber = "(123) 456 789"
      end
      o.address = Address.new.tap do |o|
        o.streetLines         = [ "123 5th St" ]
        o.city                = "San Luis Obispo"
        o.stateOrProvinceCode = "CA"
        o.postalCode          = "93401"
        o.countryCode         = "US"
        o.residential         = true
      end
    end

    label_specification = LabelSpecification.new.tap do |o|
      o.labelFormatType = LabelFormatType::COMMON2D
      o.imageType       = ShippingDocumentImageType::PDF
      o.labelStockType  = ShippingDocumentStockType::PAPER_LETTER
    end

    weights = [ 55.34, 10.2 ].map do |weight|
      Weight.new.tap do |o|
        o.units = "LB"
        o.value = weight
      end
    end

    ship_service = Service::Ship.new(credentials)

    responses = ship_service.process_shipment(
      ServiceType::FEDEX_2_DAY, shipper, recipient, label_specification, weights
    ) do |request_contents|
      request_contents.requestedShipment.requestedPackageLineItems.each do |package_line_item|
        package_line_item.customerReferences = [
          CustomerReference.new.tap do |o|
            o.customerReferenceType = CustomerReferenceType::INVOICE_NUMBER
            o.value = "INVOICE 1234"
          end
        ]
      end
    end

    tracking_numbers = responses.map do |(tracking_number, label, charge)|
      puts "tracking number: #{tracking_number}"
      puts "charge: #{charge.to_f}"
      File.open("#{tracking_number}.pdf", "w") { |f| f << label }
      tracking_number
    end

### Canceling a shipment

    ship_service.delete_shipment(
      TrackingId.new.tap do |tracking_id|
        tracking_id.trackingNumber = tracking_numbers.first
        tracking_id.trackingIdType = TrackingIdType::EXPRESS
      end
    )
