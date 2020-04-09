# frozen_string_literal: true

module DatabaseDocumenter::Exporters
  class BaseExporter
    attr_accessor :table_data, :printed_tables, :generated_cols_count, :commented_cols_count

    APP_NAME = ENV['APP_NAME']&.capitalize || "Project"
    HEADER_SECOND_LINE = "The database design specifies how the data of the software is going to be stored."

    def initialize
      self.table_data = DatabaseDocumenter::TableData.new
      self.printed_tables = []
      self.generated_cols_count = 0
      self.commented_cols_count = 0
    end

    def load_all_models
      Rails.application.eager_load!
    end

    # Skip STI classes
    # Skip duplicate tables in case of has_and_belongs_to_many
    # Skip certain modules
    def skip_class?(klass)
      (klass.class.name != klass.base_class.class.name) || klass.abstract_class? ||
        (printed_tables.include? klass.table_name) || (DatabaseDocumenter.configuration.skipped_modules.include? klass.parent.name)
    end
  end
end
