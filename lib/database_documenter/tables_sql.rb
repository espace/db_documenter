# frozen_string_literal: true
module DatabaseDocumenter::TablesSql

  def self.generate
    tables_sql = {}
    if Rails.version.split(".")[0].to_i == 4
      ActiveRecord::Tasks::MySQLDatabaseTasks.new(Rails.configuration.database_configuration['development']).structure_dump('database.sql')
    else
      ActiveRecord::Tasks::MySQLDatabaseTasks.new(Rails.configuration.database_configuration['development']).structure_dump('database.sql', {})
    end
    all_tabels_sql = IO.read('database.sql')
    all_tabels_sql = all_tabels_sql.split(';').select { |line| line.match(/CREATE/)}

    File.delete('database.sql')

    all_tabels_sql.each do |sql_statement|
      key = sql_statement.scan(/`(.*)`/)[0][0]
      broken_cell_para = Caracal::Core::Models::TableCellModel.new do |c|
        sql_statement[1..-1].squeeze(' ').split("\n").each do |p|
          c.p p
        end
      end
      tables_sql[key] = broken_cell_para

    end

    tables_sql
  end
end
