module FedexWebServices
  class DeleteShipmentRequest < Request
    def initialize
      @contents = soap_module::DeleteShipmentRequest.new
    end

    def soap_module
      FedexWebServices::Soap::Ship
    end

    def remote_method
      :deleteShipment
    end

    def service_id
      :ship
    end

    def version
      28
    end

    def delete_all_packages!(tracking_number, tracking_number_type)
      contents.deletionControl = soap_module::DeletionControlType::DELETE_ALL_PACKAGES
      contents.trackingId = soap_module::TrackingId.new.tap do |ti|
        ti.trackingNumber = tracking_number
        ti.trackingIdType = tracking_number_type
      end
    end
  end
end
