# fedex-web-services
## Description
This gem provies an interface to the FedEx web services API (version 10).  It interfaces with the FedEx web services SOAP API to look up shipping rates, generate labels, and cancel shipments (tracking coming soon).

## Setup
### Overview
This gem requires a large number of classes to communicate with FedEx.  These classes are defined by the WSDL files for the FedEx web services API.  For copyright reasons this gem does not include the files.  You will need to create a FedEx developer account to download these files (this gem works with ShipService_v10.wsdl and RateService_v10.wsdl).  I recommend putting them under your project's lib/ directory in lib/fedex/web_services/wsdl.

### Creating the class definitions
Once you have the WSDL files, you will need to create the ruby classes used in the SOAP requests.  This is a one time process that can be handled by the gem.

#### Rails
This gem includes a rake task to generate the class definitions and create an initializer to load them if you are using it from within a Rails application.  Simply save the FedEx wsdl files to a directory (lib/fedex/web_services/wsdl in this example) and include the gem in your Gemfile:

    gem 'fedex-web-services', :require => 'fedex'

Then run the following rake task

    $ WSDL_DIR=lib/fedex/web_services/wsdl rake fedex:generate_definitions

You should see output looking like this.

    Added lib/fedex/web_services/definitions/
    Added config/initializers/fedex.rb

#### Manual creation
You can also manually generate the class files.  To to this, run the following command:

    require 'fedex'
    Fedex::WebServices::Definitions.generate_definitions('lib', *Dir.glob('lib/web_services/wsdls/*.wsdl'))

This will create the directory lib/fedex/web_services/definitions/ with the FedEx web services class definitions in it.  After you have created the classes, simply include the following lines in your application to load them:

    require 'fedex'
    Fedex::WebServices::Definitions.load_definitions('lib')

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

    from = Address.new
    from.postalCode  = "93401"
    from.countryCode = "US"
    from.residential = true

    to = Address.new
    to.postalCode  = "95630"
    to.countryCode = "US"
    to.residential = true

    weight = Weight.new
    weight.units = "LB"
    weight.value = 42.42

    rate_service = Service::Rate.new(credentials)
    rate, response = rate_service.get_rates(
      ServiceType::FEDEX_2_DAY, RateRequestType::LIST, from, to, weight
    )
    puts "List rate for 42.42 lbs, 2 day from 93401 to 07541: #{rate.to_f}"


### Creating a shipment with multiple packages

    shipper = Party.new.tap do |shipper|
      shipper.contact = Contact.new.tap do |contact|
        contact.personName  = "Joe Shmoe"
        contact.phoneNumber = "(123) 456 789"
      end
      shipper.address = Address.new.tap do |address|
        address.streetLines         = [ "123 4th St" ]
        address.city                = "San Luis Obispo"
        address.stateOrProvinceCode = "CA"
        address.postalCode          = "93401"
        address.countryCode         = "US"
        address.residential         = true
      end
    end

    recipient = Party.new.tap do |recipient|
      recipient.contact = Contact.new.tap do |contact|
        contact.personName  = "Ahwahnee Hotel"
        contact.phoneNumber = "(801) 559-5000"
      end
      recipient.address = Address.new.tap do |address|
        address.streetLines         = [ "9006 Yosemite Lodge Drive" ]
        address.city                = "Yosemite National Park"
        address.stateOrProvinceCode = "CA"
        address.postalCode          = "95389"
        address.countryCode         = "US"
        address.residential         = true
      end
    end

    label_specification = LabelSpecification.new
    label_specification.labelFormatType = LabelFormatType::COMMON2D
    label_specification.imageType       = ShippingDocumentImageType::PDF
    label_specification.labelStockType  = ShippingDocumentStockType::PAPER_LETTER

    weights = [ 55.34, 10.2 ].map do |weight|
      Weight.new.tap do |w|
        w.units = "LB"
        w.value = weight
      end
    end

    ship_service = Service::Ship.new(credentials)

    responses = ship_service.process_shipment(
      ServiceType::FEDEX_2_DAY, shipper, recipient, label_specification, weights
    ) do |request_contents|
      request_contents.requestedShipment.requestedPackageLineItems.each do |package_line_item|
        package_line_item.customerReferences = [
          CustomerReference.new.tap do |customer_reference|
            customer_reference.customerReferenceType = CustomerReferenceType::INVOICE_NUMBER
            customer_reference.value = "INVOICE 1234"
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
