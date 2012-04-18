require 'stringio'

module Fedex::WebServices
  module Service
    class ServiceException < RuntimeError
      attr_accessor :details
    end

    class Base
      include Fedex::WebServices::Definitions
      include Fedex::WebServices::Request

      Credentials = Struct.new("Credentials",
        :account_number, :meter_number, :key, :password, :environment
      )

      attr_accessor :credentials
      attr_reader :wiredump

      def initialize(credentials)
        @credentials = credentials
      end

      def service_id
        raise "service_id must be implemented by subclasses of Service"
      end

      def service_url
        (@credentials.environment.to_sym == :production) ?
            'https://ws.fedex.com:443/web-services' :
            'https://wsbeta.fedex.com:443/web-services'
      end

      protected
        def port
          raise "port must be implemented by subclasses of Service"
        end

      private
        def issue_request(request)
          port = self.port
          port.wiredump_dev = StringIO.new(@wiredump = "")

          request_contents = request.contents
          yield(request_contents) if (block_given?)

          port.send(request.remote_method, request_contents).tap do |response|
            check_response(response)
          end
        rescue Exception => root_exception
          err = ServiceException.new(root_exception.message)
          err.details = root_exception.detail.fault.details.validationFailureDetail.message rescue nil
          err.set_backtrace([ "#{__FILE__}:#{__LINE__ + 1}", *root_exception.backtrace ])
          raise err
        end

        def check_response(response)
          error_notifications = response.notifications.reject do |notification|
            [
              NotificationSeverityType::SUCCESS,
              NotificationSeverityType::NOTE,
              NotificationSeverityType::WARNING
            ].include?(notification.severity)
          end

          if (error_notifications.any?)
            raise error_notifications.map(&:message) * ". "
          end
        end
    end
  end
end