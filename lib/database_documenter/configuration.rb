module DatabaseDocumenter
  class Configuration
    attr_accessor :skipped_modules, :dont_display_columns

    def initialize
      @skipped_modules = []
      @dont_display_columns = ['encrypted_password', 'current_sign_in_ip', 'remote_address', 'last_sign_in_ip']
    end
  end
end
