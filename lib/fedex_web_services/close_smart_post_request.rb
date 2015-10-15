module FedexWebServices
  class CloseSmartPostRequest < Request
    def initialize
      @contents = soap_module::SmartPostCloseRequest.new
    end

    def soap_module
      FedexWebServices::Soap::Close
    end

    def remote_method
      :smartPostClose
    end

    def service_id
      :clos
    end

    def version
      4
    end
  end
end