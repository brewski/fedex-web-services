module Fedex
  class Railtie < Rails::Railtie
    railtie_name :fedex

    rake_tasks do
      load "fedex/tasks/fedex.rake"
    end
  end
end
