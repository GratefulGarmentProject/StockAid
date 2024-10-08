require "csv"

module CsvExport
  extend ActiveSupport::Concern

  # This method can be overridden, such as in Reports::SurveyRequestData
  def csv_export_header
    self.class::FIELDS
  end

  # This method can be overridden, such as in Reports::SurveyRequestData
  def csv_export_row(row)
    self.class::FIELDS.map { |field| row.send(self.class.fields_to_method_names[field]) }
  end

  # This method can be overridden, such as in Reports::TotalInventoryValue
  def each_csv_row(&)
    each(&)
  end

  def to_csv(output = "")
    output << CSV.generate_line(csv_export_header)

    each_csv_row do |row|
      output << CSV.generate_line(csv_export_row(row))
    end

    output
  end

  class_methods do
    def fields_to_method_names
      @fields_to_method_names || self::FIELDS.to_h { |f| [f, f.underscore] }.freeze
    end
  end
end
