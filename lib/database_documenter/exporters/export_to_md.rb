# frozen_string_literal: true

module DatabaseDocumenter::Exporters
  class ExportToMd < BaseExporter
    def call
      load_all_models
      generate_md_document
    end

    def generate_md_document
      md_file_header = StringIO.new
      md_file_body = StringIO.new
      md_file = File.open("database.md", "w")

      generate_md_file_header(md_file_header)

      ActiveRecord::Base.descendants.each do |klass|
        next if skip_class?(klass)

        generate_table_metadata(md_file_header, md_file_body, klass)
        generate_table_columns(md_file_body, klass)
      end
      md_file.puts md_file_header.string
      md_file.puts md_file_body.string
      md_file.close
    end

    def generate_md_file_header(md_file_header)
      md_file_header << "# #{APP_NAME} Database Design\n"
      md_file_header << "#{HEADER_SECOND_LINE}\n"
      md_file_header << "# Tables \n"
    end

    def generate_table_metadata(md_file_header, md_file_body, klass)
      metadata = table_data.get_meta_data(klass)

      md_file_header << "- [#{klass.table_name}](##{klass.table_name})\n"

      md_file_body << "\n"
      md_file_body << "## #{klass.table_name}\n"
      md_file_body << "### Table details\n"
      md_file_body << "|Key|Value|\n"
      md_file_body << "|---|---|\n"
      md_file_body << "|Table Name|#{metadata[:name]}|\n"
      md_file_body << "|Description|#{metadata[:description]}|\n"
      md_file_body << "|Primary Key|#{metadata[:primary_key]}|\n"

      md_file_body << "\n"

      # TODO: Update DatabaseDocumenter::TableData to return this value as a String
      # And let every Exporter renders it according to the required format
      sql_code = metadata[:sql_code].contents.map(&:runs).map(&:first).map(&:text_content).join("\n")
      md_file_body << "### Table SQL Code\n"
      md_file_body << "```SQL\n"
      md_file_body << "#{sql_code}\n"
      md_file_body << "```\n"
    end

    def generate_table_columns(md_file_body, klass)
      columns_data = table_data.get_columns_data(klass)

      md_file_body << "### Table attributes\n"
      md_file_body << "|Attribute|Description|Type|Example of values|\n"
      md_file_body << "|---|---|---|---|\n"

      columns_data.each do |col|
        description = StringIO.new
        col[:description].each do |column_description|
          description << "- #{column_description}\n"
        end
        md_file_body.puts "|#{col[:name]}|#{col[:description][0]}|#{col[:type]}|#{col[:value]}|\n"
      end
      md_file_body.puts "\n"
    end
  end
end
