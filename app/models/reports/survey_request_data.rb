module Reports
  class SurveyRequestData
    include CsvExport
    attr_reader :survey_request

    def initialize(survey_request)
      @survey_request = survey_request
    end

    def csv_export_header
      columns.map(&:label)
    end

    def csv_export_row(row)
      [].tap do |result|
        row.each { |x| result << x }
      end
    end

    def columns
      @columns ||= Reports::SurveyRequestData::Columns.new(survey_request).to_a
    end

    def each
      survey_request.survey_organization_requests.each do |org_request|
        yield Reports::SurveyRequestData::Row.new(self, org_request, org_request.survey_answer&.answers)
      end
    end

    class Columns
      attr_reader :survey_request

      def initialize(survey_request)
        @survey_request = survey_request
      end

      def to_a
        [].tap do |result|
          result << organization_column

          survey_request.survey_revision.to_definition.fields.each.with_index do |field, i|
            result.push(*field_columns(field, i))
          end
        end
      end

      private

      def organization_column
        column("Organization", css_class: "sort-asc") do |org_request, _answers|
          org_request.organization.name
        end
      end

      def field_columns(field, index)
        case field
        when SurveyDef::Integer, SurveyDef::Select, SurveyDef::Text
          [simple_field_column(field, index)]
        when SurveyDef::Group
          grouped_field_columns(field, index)
        end
      end

      def simple_field_column(field, index)
        column(field.label) do |_org_request, answers|
          answers.values[index].display_value if answers
        end
      end

      def grouped_field_columns(field, index)
        [count_field_column(field, index), *grouped_nested_field_columns(field, index)]
      end

      def count_field_column(field, index)
        column("# of #{field.label}") do |_org_request, answers|
          answers.values[index].value.size if answers
        end
      end

      def grouped_nested_field_columns(field, index)
        [].tap do |result|
          field.fields.each.with_index do |grouped_field, grouped_index|
            case grouped_field
            when SurveyDef::Integer
              result.push(*grouped_integer_field_columns(grouped_field, index, grouped_index))
            end
          end
        end
      end

      def grouped_integer_field_columns(grouped_field, index, grouped_index)
        [
          grouped_integer_min_field_column(grouped_field, index, grouped_index),
          grouped_integer_max_field_column(grouped_field, index, grouped_index),
          grouped_integer_average_field_column(grouped_field, index, grouped_index),
          grouped_integer_total_field_column(grouped_field, index, grouped_index)
        ]
      end

      def grouped_integer_min_field_column(grouped_field, index, grouped_index)
        column("Min #{grouped_field.label}") do |_org_request, answers|
          answers.values[index].value.map { |x| x[grouped_index].value }.min if answers
        end
      end

      def grouped_integer_max_field_column(grouped_field, index, grouped_index)
        column("Max #{grouped_field.label}") do |_org_request, answers|
          answers.values[index].value.map { |x| x[grouped_index].value }.max if answers
        end
      end

      def grouped_integer_average_field_column(grouped_field, index, grouped_index)
        column("Avg #{grouped_field.label}") do |_org_request, answers|
          if answers
            responses = answers.values[index].value.map { |x| x[grouped_index].value }
            (responses.sum.to_f / responses.size).round(2)
          end
        end
      end

      def grouped_integer_total_field_column(grouped_field, index, grouped_index)
        column("Total #{grouped_field.label}") do |_org_request, answers|
          answers.values[index].value.map { |x| x[grouped_index].value }.sum if answers
        end
      end

      def column(label, css_class: nil, &apply_fn)
        Reports::SurveyRequestData::Column.new(label, css_class: css_class, &apply_fn)
      end
    end

    class Column
      attr_reader :label, :css_class

      def initialize(label, css_class: nil, &apply_fn)
        @label = label
        @css_class = css_class
        @apply_fn = apply_fn
      end

      def apply(org_request, answers)
        @apply_fn.call(org_request, answers)
      end
    end

    class Row
      attr_reader :data, :org_request, :answers

      def initialize(data, org_request, answers)
        @data = data
        @org_request = org_request
        @answers = answers
      end

      def status_class
        org_request.status_class
      end

      def each
        data.columns.each do |column|
          yield(column.apply(org_request, answers))
        end
      end
    end
  end
end
