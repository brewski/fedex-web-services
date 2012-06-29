module Fedex
  module Generators
    class GenerateDefinitionsGenerator < ::Rails::Generators::Base
      FEDEX_INITIALIZER_FILE = File.join(Rails.root, 'config', 'initializers', 'fedex.rb')

      class_option :wsdl_dir,
          default: File.join(%w(lib fedex web_services wsdl)),
          type:    :string,
          desc:    "directory where the fedex wsld files are stored"


      class_option :skip_initializer,
          default: false,
          type:    :boolean,
          desc:    "install a rails initializer to load the wsdl definitions"

      desc "Generate the FedEx WebServices class definitions and create an initializer to load them"

      def install
        wsdl_dir = options[:wsdl_dir]
        wsdl_files = Dir.glob(File.join(wsdl_dir, '*.wsdl'))
        target_lib_dir = File.join(Rails.root, 'lib')

        if (wsdl_files.empty?)
          say("Could not find any wsdl files in #{wsdl_dir}", :red)
        else
          Fedex::WebServices::Definitions.generate_definitions(target_lib_dir, *wsdl_files)
          say("Added #{File.join(target_lib_dir, Fedex::WebServices::Definitions::MODULE_PATH)}", :green)

          unless (options[:skip_initializer])
            create_file(FEDEX_INITIALIZER_FILE,
                "Fedex::WebServices::Definitions.load_definitions('#{target_lib_dir}')")
          end
        end
      end
    end
  end
end