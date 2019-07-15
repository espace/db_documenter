module DatabaseDocumenter
  class DatabaseComment::PostgresDatabaseComment < DatabaseComment::BaseDatabaseComment
    def self.read_columns_comment(table_name)
      select_comment = <<-SQL
        SELECT
          cols.column_name,
          (
            SELECT
                pg_catalog.col_description(c.oid, cols.ordinal_position::int)
            FROM
                pg_catalog.pg_class c
            WHERE
                c.oid = (SELECT ('"' || cols.table_name || '"')::regclass::oid)
                AND c.relname = cols.table_name
          ) AS column_comment
        FROM
            information_schema.columns cols
        WHERE
            cols.table_catalog    = '#{database_name}'
            AND cols.table_name   = '#{table_name}'
            AND cols.table_schema = 'public';
      SQL

      columns_comment_hash = {}
      ActiveRecord::Base.connection.execute(select_comment).map { |c| columns_comment_hash[c['column_name']] = c['column_comment'] }
      columns_comment_hash
    end

    def self.read_table_comment(table_name)
      select_comment = <<-SQL
        select obj_description('public.#{table_name}'::regclass);
      SQL

      ActiveRecord::Base.connection.execute(select_comment)[0]['obj_description']
    end
  end
end
