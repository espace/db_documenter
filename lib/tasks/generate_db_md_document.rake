require "bundler/setup"
require "database_documenter"

task generate_db_md_document: :environment do
  DatabaseDocumenter::Exporters::ExportToMd.new.call
end
