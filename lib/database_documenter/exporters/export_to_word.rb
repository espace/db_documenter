# frozen_string_literal: true

module DatabaseDocumenter::Exporters
  class ExportToWord
    attr_accessor :table_data, :printed_tables, :generated_cols_count, :commented_cols_count

    def initialize
      self.table_data = DatabaseDocumenter::TableData.new
      self.printed_tables = []
      self.generated_cols_count = 0
      self.commented_cols_count = 0
    end

    def call
      load_all_models
      generate_word_document
    end

    def load_all_models
      Rails.application.eager_load!
    end

    def generate_word_document
      Caracal::Document.save 'database.docx' do |docx|
        add_word_header(docx)
        add_word_footer(docx)

        ActiveRecord::Base.descendants.each do |klass|
          # Skip STI classes
          # Skip duplicate tables in case of has_and_belongs_to_many
          # Skip certain modules
          next if skip_class?(klass)

          printed_tables << klass.table_name

          generate_table_metadata(docx, klass)
          generate_table_columns(docx, klass)

          docx.page
        end
      end
      Rails.logger.info "Number of columns with generated description #{generated_cols_count}"
      Rails.logger.info "Number of columns with description from comments #{commented_cols_count}"
    end

    def add_word_footer(docx)
      docx.page_numbers true do
        align 'center'
        label DatabaseDocumenter.configuration.footer.to_s
      end
    end

    def add_word_header(docx)
      docx.h1 "Database Design"
      docx.p "The database design specifies how the data of the software is going to be stored."
    end

    def skip_class?(klass)
      (klass.class_name != klass.base_class.class_name) || klass.abstract_class? || (klass == ActiveAdmin::Comment) ||
        (printed_tables.include? klass.table_name) || (DatabaseDocumenter.configuration.skipped_modules.include? klass.parent.name)
    end

    def generate_table_metadata(docx, klass)
      metadata = table_data.get_meta_data(klass)
      docx.p ''
      docx.h2 "#{klass.table_name} schema"
      docx.hr

      word_table = [
        ["Table Name", metadata[:name]],
        ["Description", metadata[:description]],
        ["Primary Key", metadata[:primary_key]],
        ["SQL Code", metadata[:sql_code]]
      ]

      docx.table word_table, border_size: 4 do
        cell_style rows[0][0], background: 'b4b4b4', bold: true, width: 2000
        cell_style rows[1][0], background: 'e0e0e0', bold: true, width: 2000
        cell_style rows[2][0], background: 'e0e0e0', bold: true, width: 2000
        cell_style rows[3][0], background: 'e0e0e0', bold: true, width: 2000
      end
    end

    def generate_table_columns(docx, klass)
      columns_header = ["Attribute", "Description", "Type", "Example of values"]
      columns = []

      columns_data = table_data.get_columns_data(klass)

      columns_data.each do |col|
        data = [col[:name]]
        if col[:description_generated]
          self.generated_cols_count += 1
        else
          self.commented_cols_count += 1
        end

        broken_cell_para = Caracal::Core::Models::TableCellModel.new do |c|
          col[:description].flatten.each do |s|
            c.p s
          end
        end

        data << broken_cell_para
        data << col[:type]
        data << col[:value]
        columns << data
      end
      docx.page
      docx.table [columns_header] + columns, border_size: 4 do
        cell_style rows[0], background: 'e0e0e0', bold: true
      end
    end
  end
end
