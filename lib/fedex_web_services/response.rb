module FedexWebServices
  class Response
    attr_reader :contents

    def initialize(contents)
      @contents = contents
    end

    def errors
      contents.notifications.reject do |notification|
        [ "SUCCESS", "NOTE", "WARNING" ].include?(notification.severity)
      end
    end
  end
end

