require "database_documenter/version"
require 'database_documenter/database_comment'
require 'database_documenter/tables_sql'
require 'database_documenter/column_description'
require 'caracal'
require "database_documenter/railtie" if defined?(Rails)

module DatabaseDocumenter
  class Error < StandardError; end
end
