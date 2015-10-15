module FedexWebServices
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../../../tasks/test.rake", __FILE__)
    end
  end
end