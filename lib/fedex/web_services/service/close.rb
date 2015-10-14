module Fedex::WebServices
  module Service
    class Close < Base
      def service_id
        :clos
      end

      def service_version
        4
      end

      def close_smart_post
        issue_request(CloseSmartPost.new(self))
      end

      protected
        def port
          ClosePortType.new(service_url)
        end
    end
  end
end