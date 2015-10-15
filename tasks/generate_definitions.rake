task :generate_definitions do
  require 'wsdl/soap/wsdl2ruby'

  require 'fileutils'

  module_path = File.join(%w(lib fedex_web_services soap))

  Dir.glob(File.expand_path("../../wsdl/*.wsdl", __FILE__)).each do |wsdl_file|
    service = File.basename(wsdl_file).gsub(/^(.+?)Service.*wsdl/, "\\1")

    worker = WSDL::SOAP::WSDL2Ruby.new
    worker.basedir = FileUtils.mkdir_p(File.join(module_path)).first
    worker.location = File.new(wsdl_file).path
    worker.logger.level = Logger::WARN
    worker.opt.update(
        "module_path"      => "FedexWebServices::Soap::#{service}",
        "mapping_registry" => nil,
        "driver"           => nil,
        "classdef"         => nil
    )
    worker.run
  end
end
