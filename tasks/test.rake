namespace :fedex_web_services do
  task :test do
    Dir.glob(File.expand_path("../../test/*.rb", __FILE__)).each { |file| require file }
  end
end