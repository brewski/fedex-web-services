module FedexWebServices
end

require "fedex_web_services/soap"

require 'fedex_web_services/request'
require 'fedex_web_services/close_smart_post_request'
require 'fedex_web_services/delete_shipment_request'
require 'fedex_web_services/process_shipment_request'
require 'fedex_web_services/upload_images_request'

require "fedex_web_services/api"

require "fedex_web_services/railtie" if (defined?(Rails))
