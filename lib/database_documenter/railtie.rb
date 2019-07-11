class DatabaseDocumenter::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/generate_db_document.rake'
    load 'tasks/generate_dd_initializer.rake'
  end
end
