module Fedex
  module WebServices
    module Definitions
      extend(self)

      MODULE_PATH = File.join(%w(fedex web_services definitions))

      def load_definitions(lib_dir)
        $VERBOSE = $VERBOSE.tap do
          $VERBOSE = nil

          $:.unshift(lib_dir)
          $:.unshift(File.join(lib_dir, MODULE_PATH))
          Dir.glob(File.join(lib_dir, MODULE_PATH, "*DefinitionsDriver.rb")).each do |definition_file|
            begin
              require File.join(MODULE_PATH, File.basename(definition_file))
            rescue Exception
              raise "Error loading Fedex definition file #{definition_file}: #{$!.message}"
            end
          end
          $:.shift
          $:.shift
        end
      end

      def generate_definitions(lib_dir, *wsdl_files)
        require 'wsdl/soap/wsdl2ruby'
        require 'fileutils'

        wsdl_files.each do |wsdl_file|
          worker = WSDL::SOAP::WSDL2Ruby.new
          worker.basedir = FileUtils.mkdir_p(File.join(Dir.new(lib_dir), MODULE_PATH)).first
          worker.location = File.new(wsdl_file).path
          worker.logger.level = Logger::WARN
          worker.opt.update(
            "module_path"      => "Fedex::WebServices::Definitions",
            "mapping_registry" => nil,
            "driver"           => nil,
            "classdef"         => nil
          )
          worker.run
        end
      end
    end
  end
end