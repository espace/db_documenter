require "bundler/setup"
require "database_documenter"

task generate_db_document: :environment do
  Rails.application.eager_load!

  tables_sql = DatabaseDocumenter::TablesSql.generate

  Caracal::Document.save 'database.docx' do |docx|
    database_comment_class = DatabaseDocumenter::DatabaseComment.get_comment_class

    docx.page_numbers true do
      align 'center'
      label "#{DatabaseDocumenter.configuration.footer}"
    end

    docx.h1 "Database Design"
    docx.p "The database design specifies how the data of the software is going to be stored."

    printed_tables = []
    generated_col_description = 0
    col_description_from_comments = 0
    ActiveRecord::Base.descendants.each do |klass|
      next if (klass.class_name != klass.base_class.class_name) || klass.abstract_class? || klass == ActiveAdmin::Comment # Ignore STI classes

      next if printed_tables.include? klass.table_name # Skip duplicate tables in case of has_and_belongs_to_many

      next if DatabaseDocumenter.configuration.skipped_modules.include? klass.parent.name

      printed_tables << klass.table_name

      table_comment = database_comment_class.read_table_comment(klass.table_name)

      docx.p ''
      docx.h2 "#{klass.table_name} schema"
      docx.hr

      table_name = ["Table Name", klass.table_name]
      description = ["Description", (table_comment.nil? || table_comment.empty?) ? "A collection of data related to #{klass.table_name.titleize}" : table_comment ]
      primary_key = ["Primary Key", klass.primary_key]
      sql_code = ["SQL Code", tables_sql[klass.table_name]]

      docx.table [table_name, description, primary_key, sql_code], border_size: 4 do
        cell_style rows[0][0], background: 'b4b4b4', bold: true, width: 2000
        cell_style rows[1][0], background: 'e0e0e0', bold: true, width: 2000
        cell_style rows[2][0], background: 'e0e0e0', bold: true, width: 2000
        cell_style rows[3][0], background: 'e0e0e0', bold: true, width: 2000
      end

      columns_header = ["Attribute", "Description", "Type", "Example of values"]
      columns = []
      sample_record = klass.first
      columns_comments = database_comment_class.read_columns_comment(klass.table_name)
      klass.columns.each do |col|
        column_data = [col.name]
        if columns_comments[col.name].present?
          col_description_from_comments +=1
          broken_cell_para = Caracal::Core::Models::TableCellModel.new do |c|
            columns_comments[col.name].split("<br/>").each do |s|
              c.p s
            end
          end
          column_data << broken_cell_para
        else
          generated_col_description +=1
          column_data << DatabaseDocumenter::ColumnDescription.generate(col.name, col.type, klass)
        end

        column_data << col.type

        hidden_values_columns = DatabaseDocumenter.configuration.hidden_values_columns

        if hidden_values_columns.include?(col.name)
          column_data << 'Data is hidden/removed'
        elsif sample_record.nil?
          column_data << ''
        else
          if Rails.version.split(".")[0].to_i == 4
            column_data << sample_record[col.name]
          else
            column_data << sample_record.send("#{col.name}_before_type_cast")
          end
        end

        columns << column_data
      end
      docx.page
      docx.table [columns_header] + columns, border_size: 4 do
        cell_style rows[0], background: 'e0e0e0', bold: true
      end
      docx.page
    end
    puts "Number of columns with generated description #{generated_col_description}"
    puts "Number of columns with description from comments #{col_description_from_comments}"
  end
end
