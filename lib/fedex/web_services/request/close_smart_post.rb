module Fedex::WebServices
  module Request
    class CloseSmartPost < Base
      def remote_method
        :smartPostClose
      end

      def contents
        SmartPostCloseRequest.new.tap do |spcr|
          spcr.webAuthenticationDetail = web_authentication_detail
          spcr.clientDetail            = client_detail
          spcr.version                 = version
        end
      end
    end
  end
end