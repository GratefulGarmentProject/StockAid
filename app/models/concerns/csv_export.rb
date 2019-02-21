require "csv"

module CsvExport
  extend ActiveSupport::Concern

  def to_csv(output = "")
    output << CSV.generate_line(self.class::FIELDS)

    each do |row|
      output << CSV.generate_line(self.class::FIELDS.map { |field| row.send(self.class.fields_to_method_names[field]) })
    end

    output
  end

  class_methods do
    def fields_to_method_names
      @fields_to_method_names || Hash[self::FIELDS.map { |f| [f, f.underscore] }].freeze
    end
  end
end
