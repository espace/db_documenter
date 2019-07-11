DatabaseDocumenter.configure do |config|
  config.skipped_modules = %w(NAMESPACE)
  config.hidden_values_columns = %w(col1 col2)
end