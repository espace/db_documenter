module DatabaseDocumenter
  module DatabaseComment
    def self.get_comment_class(adapter = get_current_adapter)
      if  adapter == "postgresql"
        DatabaseDocumenter::DatabaseComment::PostgresDatabaseComment
      else
        DatabaseDocumenter::DatabaseComment::MysqlDatabaseComment
      end
    end

    def self.get_current_adapter
      DatabaseDocumenter.configuration.database_configuration['adapter']
    end
  end
end
