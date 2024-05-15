require 'fedex_web_services/upload_images_response'

module FedexWebServices
  class UploadImagesRequest < Request
    def initialize
      @contents = soap_module::UploadImagesRequest.new
    end

    def soap_module
      FedexWebServices::Soap::UploadDocument
    end

    def remote_method
      :uploadImages
    end

    def service_id
      :cdus
    end

    def version
      19
    end

    def issue_request(port, credentials)
      UploadImagesResponse.new(port.send(remote_method, request_contents(credentials)))
    end
  end
end
