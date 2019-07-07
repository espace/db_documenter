require 'database_documenter/configuration'
require "database_documenter/version"
require 'database_documenter/database_comment'
require 'database_documenter/tables_sql'
require 'database_documenter/column_description'
require 'caracal'
require "database_documenter/railtie" if defined?(Rails)

module DatabaseDocumenter
  class Error < StandardError; end
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
