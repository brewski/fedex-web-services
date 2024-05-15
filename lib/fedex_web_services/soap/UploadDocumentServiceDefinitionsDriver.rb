# encoding: UTF-8
# Generated by wsdl2ruby (SOAP4R-NG/2.0.4)
require_relative 'UploadDocumentServiceDefinitions.rb'
require_relative 'UploadDocumentServiceDefinitionsMappingRegistry.rb'
require 'soap/rpc/driver'

module FedexWebServices::Soap::UploadDocument

class UploadDocumentPortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "https://wsbeta.fedex.com:443/web-services/uploaddocument"

  Methods = [
    [ "http://fedex.com/ws/uploaddocument/v19/uploadDocuments",
      "uploadDocuments",
      [ [:in, "UploadDocumentsRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/uploaddocument/v19", "UploadDocumentsRequest"]],
        [:out, "UploadDocumentsReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/uploaddocument/v19", "UploadDocumentsReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://fedex.com/ws/uploaddocument/v19/uploadDocumentsWithShipmentData",
      "uploadDocumentsWithShipmentData",
      [ [:in, "UploadDocumentsWithShipmentDataRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/uploaddocument/v19", "UploadDocumentsWithShipmentDataRequest"]],
        [:out, "UploadDocumentsWithShipmentDataReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/uploaddocument/v19", "UploadDocumentsWithShipmentDataReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://fedex.com/ws/uploaddocument/v19/uploadImages",
      "uploadImages",
      [ [:in, "UploadImagesRequest", ["::SOAP::SOAPElement", "http://fedex.com/ws/uploaddocument/v19", "UploadImagesRequest"]],
        [:out, "UploadImagesReply", ["::SOAP::SOAPElement", "http://fedex.com/ws/uploaddocument/v19", "UploadImagesReply"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = UploadDocumentServiceDefinitionsMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = UploadDocumentServiceDefinitionsMappingRegistry::LiteralRegistry
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
