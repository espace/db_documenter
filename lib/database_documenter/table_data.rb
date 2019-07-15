# frozen_string_literal: true

class DatabaseDocumenter::TableData
  attr_accessor :tables_sql, :database_comment_class

  def initialize
    self.database_comment_class = DatabaseDocumenter::DatabaseComment.get_comment_class
    load_tables_sql_data
  end

  def load_tables_sql_data
    self.tables_sql = DatabaseDocumenter::TablesSql.generate
  end

  def get_meta_data(klass)
    table_comment = database_comment_class.read_table_comment(klass.table_name)

    data = {}
    data[:name] = klass.table_name
    data[:description] = table_comment.presence || "A collection of data related to #{klass.table_name.titleize}"
    data[:primary_key] = klass.primary_key
    data[:sql_code] = tables_sql[klass.table_name]
    data
  end

  def get_columns_data(klass)
    sample_record = klass.first
    columns_comments = database_comment_class.read_columns_comment(klass.table_name)
    columns = []
    klass.columns.each do |col|
      column_data = get_column_data(klass, col, sample_record, columns_comments[col.name])

      columns << column_data
    end
    columns
  end

  def get_column_data(klass, col, sample_record, column_comment)
    column_data = { name: col.name }
    column_data[:description] = []

    if column_comment.present?
      column_data[:description_generated] = false
      column_comment.split("<br/>").each do |s|
        column_data[:description] << s
      end
    else
      column_data[:description_generated] = true
      column_data[:description] << DatabaseDocumenter::ColumnDescription.generate(col.name, col.type, klass)
    end

    column_data[:type] = col.type

    hidden_values_columns = DatabaseDocumenter.configuration.hidden_values_columns

    column_data[:value] = if hidden_values_columns.include?(col.name)
                            'Data is hidden/removed'
                          elsif sample_record.nil?
                            ''
                          elsif Rails.version.split(".")[0].to_i == 4
                            sample_record[col.name]
                          else
                            sample_record.send("#{col.name}_before_type_cast")
                          end
    column_data
  end
end
