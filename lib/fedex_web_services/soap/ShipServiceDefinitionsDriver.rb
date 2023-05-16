# encoding: UTF-8
# Generated by wsdl2ruby (SOAP4R-NG/2.0.4)
require_relative 'ShipServiceDefinitions.rb'
require_relative 'ShipServiceDefinitionsMappingRegistry.rb'
require 'soap/rpc/driver'

module FedexWebServices::Soap::Ship

class ShipPortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "https://wsbeta.fedex.com:443/web-services/ship"

  Methods = [
    [ "http://fedex.com/ws/ship/v28/processTag",
      "processTag",
      [ [:in, "ProcessTagRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ProcessTagRequest"]],
        [:out, "ProcessTagReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ProcessTagReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://fedex.com/ws/ship/v28/processShipment",
      "processShipment",
      [ [:in, "ProcessShipmentRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ProcessShipmentRequest"]],
        [:out, "ProcessShipmentReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ProcessShipmentReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://fedex.com/ws/ship/v28/deleteTag",
      "deleteTag",
      [ [:in, "DeleteTagRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "DeleteTagRequest"]],
        [:out, "ShipmentReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ShipmentReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://fedex.com/ws/ship/v28/deleteShipment",
      "deleteShipment",
      [ [:in, "DeleteShipmentRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "DeleteShipmentRequest"]],
        [:out, "ShipmentReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ShipmentReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://fedex.com/ws/ship/v28/validateShipment",
      "validateShipment",
      [ [:in, "ValidateShipmentRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ValidateShipmentRequest"]],
        [:out, "ShipmentReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/ship/v28", "ShipmentReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = ShipServiceDefinitionsMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = ShipServiceDefinitionsMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end


end
