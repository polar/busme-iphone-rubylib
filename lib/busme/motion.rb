unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), '**/*.rb')).each do |file|
   #puts file
    app.files << file
  end

  def j(file); File.join(File.dirname(__FILE__), file); end

  app.files_dependencies j("platform/platform_api.rb") => j("integration/http/http_client.rb")

  app.files_dependencies j("iphone/http/http_client.rb") => j("integration/http/http_client.rb")
  app.files_dependencies j("iphone/api.rb") => j("platform/platform_api.rb")
  app.files.delete j("motion.rb")
  app.files.each do |file|
    p file
  end
end