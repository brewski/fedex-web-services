# fedex-web-services
## Description
This gem provides an interface to the FedEx web services API.  It supports version 12 of the ship service and version 4 of the close service.

## Examples
### Creating a shipment with multiple packages

```ruby
require 'fedex_web_services'

include FedexWebServices
include FedexWebServices::Soap

credentials = Api::Credentials.new(
  ENV.fetch('FEDEX_ACCOUNT'),
  ENV.fetch('FEDEX_METER'),
  ENV.fetch('FEDEX_AUTH_KEY'),
  ENV.fetch('FEDEX_SECURITY_CODE'),
  :test # or :production
)
api = Api.new(credentials)

service = Ship::ServiceType::FEDEX_2_DAY

from = Ship::Party.new.tap do |shipper|
  shipper.contact = Ship::Contact.new.tap do |contact|
    contact.personName  = "Joe Shmoe"
    contact.phoneNumber = "(123) 456 789"
  end

  shipper.address = Ship::Address.new.tap do |address|
    address.streetLines         = [ "123 4th St" ]
    address.city                = "San Luis Obispo"
    address.stateOrProvinceCode = "CA"
    address.postalCode          = "93401"
    address.countryCode         = "US"
    address.residential         = true
  end
end

to = Ship::Party.new.tap do |recipient|
  recipient.contact = Ship::Contact.new.tap do |contact|
    contact.personName  = "Ahwahnee Hotel"
    contact.phoneNumber = "(801) 559-5000"
  end
  recipient.address = Ship::Address.new.tap do |address|
    address.streetLines         = [ "9006 Yosemite Lodge Drive" ]
    address.city                = "Yosemite National Park"
    address.stateOrProvinceCode = "CA"
    address.postalCode          = "95389"
    address.countryCode         = "US"
    address.residential         = true
  end
end

label_spec = Ship::LabelSpecification.new
label_spec.labelFormatType = Ship::LabelFormatType::COMMON2D
label_spec.imageType       = Ship::ShippingDocumentImageType::PDF
label_spec.labelStockType  = Ship::ShippingDocumentStockType::PAPER_LETTER

weights = [ 10, 55.34, 10.2 ].map do |weight|
  Ship::Weight.new.tap do |w|
    w.units = "LB"
    w.value = weight
  end
end

requests = ProcessShipmentRequest.shipment_requests(service, from, to, label_spec, weights)
requests.each do |request|
  request.sender_paid!(credentials.account_number)
  request.list_rate!
  request.regular_pickup!
  request.customer_reference!("01234")
  request.customer_invoice!("56789")
end

tracking_numbers = api.process_shipments(requests).map do |response|
  filename = "#{response.tracking_number}.pdf"
  File.write(filename, response.label)
  puts "Wrote #{filename}"
  response.tracking_number
end
```

### Canceling a shipment

```ruby
tracking_numbers.each do |tracking_number|
  delete_request = DeleteShipmentRequest.new
  delete_request.delete_all_packages!(tracking_number, Ship::TrackingIdType::EXPRESS)
  api.delete_shipment(delete_request)
  puts "Deleted shipment #{tracking_number}"
end
```

### Debugging
You can see the SOAP wiredump by accessing Api#wiredump after issuing a request.
```ruby
begin
  api.process_shipments(...)
rescue
  puts api.wiredump
  raise $!
end
```
