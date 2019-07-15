task :generate_dd_initializer do
  template_path = File.join(File.dirname(__FILE__), 'templates/database_documenter.rb').freeze
  initializer_path = 'config/initializers/database_documenter.rb'.freeze
  # Check if the initializer already exists
  abort("Initializer already exists") if File.file?(initializer_path)

  # Copy the template to the initializers dir
  FileUtils.cp(template_path, initializer_path)
end
