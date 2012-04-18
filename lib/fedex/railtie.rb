module Fedex
  class Railtie < Rails::Railtie
    rake_tasks do
      load "fedex/tasks/fedex.rake"
    end
  end
end
