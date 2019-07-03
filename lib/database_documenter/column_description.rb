# frozen_string_literal: true
module DatabaseDocumenter::ColumnDescription

  def self.generate(column_name, column_type, klass)
    klass_name = klass.name.demodulize.titleize

    # handle enums
    if klass.defined_enums.keys.include?(column_name)
      return generate_enum_column_description(column_name, column_type, klass_name, klass)
    end

    # handle assm
    if klass.respond_to?(:aasm) && klass.aasm.attribute_name.to_s == column_name
      return generate_assm_column_description(column_name, column_type, klass_name, klass)
    elsif klass.subclasses.select { |x| x.respond_to?(:aasm) }[0] != nil
      subklass = klass.subclasses.select { |x| x.respond_to?(:aasm) }[0]
      if subklass.aasm.attribute_name.to_s == column_name
        return generate_assm_column_description(column_name, column_type, klass_name, subklass)
      end
    end

    # Default
    if self.respond_to?("generate_#{column_type}_column_description")
      send("generate_#{column_type}_column_description", column_name, column_type, klass_name)
    else
      self.generate_with_default_rules(column_name, column_type, klass_name, klass)
    end
  end

  def self.generate_datetime_column_description(column_name, column_type, klass_name)
    case column_name
    when 'remember_created_at'
      "Date when remember me created"
    when 'reset_password_sent_at'
      "Date when reset password sent"
    when 'current_sign_in_at'
      "Date when the user current signed in"
    when "last_sign_in_at"
      "Date when the user last signed in"
    when 'remember_created_at'
      "Date when remember token created"
    when /.*_at/
      "Date when the row was #{column_name.titlecase.downcase[0..-4]}"
    else
      "Date when the row was #{column_name.titlecase.downcase}"
    end
  end

  def self.generate_boolean_column_description(column_name, column_type, klass_name)
    case column_name
    when /.*active/, /has_.*/, "canceled"
      "Is #{klass_name.titlecase.downcase} #{column_name.titlecase.downcase}"
    when /is_.*/
      column_name.titlecase.downcase
    else
      "Is #{klass_name.titlecase.downcase} has #{column_name.titlecase.downcase}"
    end
  end

  def self.generate_with_default_rules(column_name, column_type, klass_name, klass)
    case column_name
    when 'type'
      values_hash = Hash[klass.subclasses.collect { |k| [k.name.underscore.humanize, k.name] } ]
      represent_multi_value_column(column_name, klass_name, values_hash)
    when /.*_code/
      refered_table_name = column_name.scan(/(.*)_code/)[0][0]
      "Code of #{refered_table_name.titleize}".capitalize
    when /.*_id/
      refered_table_name = column_name.scan(/(.*)_id/)[0][0]
      "Id of #{refered_table_name.titleize}".capitalize
    when /.*_type/
      refered_table_name = column_name.scan(/(.*)_type/)[0][0]
      "Type of #{refered_table_name.titleize}".capitalize
    when /.*_count/
      refered_table_name = column_name.scan(/(.*)_count/)[0][0]
      "Count of #{refered_table_name.titleize}".capitalize
    else
      "#{column_name.titlecase.downcase} of #{klass_name.titleize}".capitalize
    end
  end

  def self.generate_enum_column_description(column_name, column_type, klass_name, klass)
    values_hash = klass.defined_enums[column_name]
    represent_multi_value_column(column_name, klass_name, values_hash)
  end

  def self.generate_assm_column_description(column_name, column_type, klass_name, klass)
    values_hash = Hash[klass.aasm.states.collect { |k| [k.name.to_s.humanize, k.name.to_s] } ]
    represent_multi_value_column(column_name, klass_name, values_hash)
  end

  def self.represent_multi_value_column(column_name, klass_name, values_hash)
    broken_cell_para = Caracal::Core::Models::TableCellModel.new do |c|
      c.p "#{column_name.titlecase.downcase} of #{klass_name.titleize}, possible values:"
      values_hash.each do |k,v|
        if k == values_hash.keys.last
          c.p "[#{v}] => #{k}."
        else
          c.p "[#{v}] => #{k},"
        end
      end
    end
     broken_cell_para
  end
end
