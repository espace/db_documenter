module DatabaseDocumenter
  class Configuration
    attr_accessor :skipped_modules, :hidden_values_columns, :database_configuration, :footer

    def initialize
      @skipped_modules = []
      @hidden_values_columns = %w[encrypted_password current_sign_in_ip remote_address last_sign_in_ip]
      @database_configuration = Rails.application.config.database_configuration[Rails.env]
      @footer = ''
    end
  end
end
