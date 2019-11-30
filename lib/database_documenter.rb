require 'database_documenter/configuration'
require "database_documenter/version"
require 'database_documenter/database_comment'
require 'database_documenter/database_comment/base_database_comment'
require 'database_documenter/database_comment/mysql_database_comment'
require 'database_documenter/database_comment/postgres_database_comment'
require 'database_documenter/tables_sql'
require 'database_documenter/column_description'
require 'database_documenter/table_data'
require 'database_documenter/exporters/base_exporter'
require 'database_documenter/exporters/export_to_word'
require 'database_documenter/exporters/export_to_md'
require 'caracal'
require "database_documenter/railtie" if defined?(Rails)

module DatabaseDocumenter
  class Error < StandardError; end
  class << self
    attr_writer :configuration
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
