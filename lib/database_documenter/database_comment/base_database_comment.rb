# frozen_string_literal: true
# A base class for reading column database comments
  class DatabaseDocumenter::DatabaseComment::BaseDatabaseComment

    def self.read_columns_comment(table_name)
      raise NotImplementedError
    end

    def self.read_table_comment(table_name)
      raise NotImplementedError
    end

    def self.database_name
    	Rails.application.config.database_configuration[Rails.env]['database'].freeze
    end
  end
