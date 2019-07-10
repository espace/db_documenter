# frozen_string_literal: true
module DatabaseDocumenter::TablesSql

  def self.generate

    configuration = DatabaseDocumenter.configuration.database_configuration

    tables_sql = generate_sql_file(configuration)

    self.send("process_#{configuration['adapter']}_sql", tables_sql)
  end

  def self.generate_sql_file(configuration)
    ActiveRecord::Tasks::DatabaseTasks.structure_dump(configuration, 'database.sql')
    tables_sql = IO.read('database.sql')
    File.delete('database.sql')
    tables_sql
  end

  def self.process_postgresql_sql(tables_sql)
    tables_sql_hash = {}
    tables_sql = tables_sql.split('--').select { |line| line.match(/CREATE TABLE/)}

    tables_sql.each do |sql_statement|
      key = sql_statement.scan(/public.(.*) \(/)[0][0]
      broken_cell_para = Caracal::Core::Models::TableCellModel.new do |c|
        sql_statement.strip.squeeze(' ').split("\n").each do |p|
          c.p p
        end
      end
      tables_sql_hash[key] = broken_cell_para

    end

    tables_sql_hash
  end

  def self.process_mysql2_sql(tables_sql)
    tables_sql_hash = {}
    tables_sql = tables_sql.split(';').select { |line| line.match(/CREATE/)}

    tables_sql.each do |sql_statement|
      key = sql_statement.scan(/`(.*)`/)[0][0]
      broken_cell_para = Caracal::Core::Models::TableCellModel.new do |c|
        sql_statement[1..-1].squeeze(' ').split("\n").each do |p|
          c.p p
        end
      end
      tables_sql_hash[key] = broken_cell_para

    end

    tables_sql_hash
  end
end
