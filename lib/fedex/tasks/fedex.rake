namespace :fedex do
  desc "Generate the ruby definition files from the FedEx wsdl files"
  task :generate_definitions do
    wsdl_dir = ENV['WSDL_DIR']
    if (!Dir.exist?(wsdl_dir || ""))
      puts "Set the WSDL_DIR environment variable to location of the Fedex wsdl files"
    else
      Fedex::WebServices::Definitions.generate_definitions(
        File.join(Rails.root, 'lib'),
        *Dir.glob(File.join(ENV['WSDL_DIR'], '*.wsdl'))
      )

      File.open(File.join(Rails.root, 'config', 'initializers', 'fedex.rb'), "w") do |file|
        file.puts "Fedex::WebServices::Definitions.load_definitions('lib')"
      end

      puts "Added lib/fedex/web_services/definitions/"
      puts "Added config/initializers/fedex.rb"
    end
  end
end