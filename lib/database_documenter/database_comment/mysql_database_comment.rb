module DatabaseDocumenter
  class DatabaseComment::MysqlDatabaseComment < DatabaseComment::BaseDatabaseComment

    def self.read_columns_comment(table_name)

      select_comment = <<-SQL
        SELECT `column_name`, `column_comment`
        FROM `information_schema`.`COLUMNS`
        WHERE `table_name` = '#{table_name}'
        AND `table_schema` = '#{database_name}'
        AND `column_comment` != '';
      SQL

      ActiveRecord::Base.connection.execute(select_comment).to_h
    end

    def self.read_table_comment(table_name)
      select_comment = <<-SQL
        SELECT `TABLE_COMMENT`
        FROM `information_schema`.`TABLES`
        WHERE `TABLE_NAME` = '#{table_name}'
        AND `table_schema` = '#{database_name}';
      SQL

      ActiveRecord::Base.connection.execute(select_comment).to_a.try('[]', 0).try('[]', 0)
    end
  end
end
