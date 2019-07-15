require "bundler/setup"
require "database_documenter"

task generate_db_document: :environment do
  DatabaseDocumenter::Exporters::ExportToWord.new.call
end
