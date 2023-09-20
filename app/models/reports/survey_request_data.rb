module Reports
  class SurveyRequestData
    attr_reader :survey_request

    def initialize(survey_request)
      @survey_request = survey_request
    end

    def columns
      @columns ||= [].tap do |result|
        result << Reports::SurveyRequestData::Column.new("Organization", css_class: "sort-asc") { |org_request, _answers| org_request.organization.name }

        survey_request.survey_revision.to_definition.fields.each.with_index do |field, i|
          case field
          when SurveyDef::Integer, SurveyDef::Select, SurveyDef::Text
            result << Reports::SurveyRequestData::Column.new(field.label) do |_org_request, answers|
              if answers
                answers.values[i].display_value
              end
            end
          when SurveyDef::Group
            result << Reports::SurveyRequestData::Column.new("# of #{field.label}") do |_org_request, answers|
              if answers
                answers.values[i].value.size
              end
            end

            field.fields.each.with_index do |grouped_field, j|
              case grouped_field
              when SurveyDef::Integer
                result << Reports::SurveyRequestData::Column.new("Min #{grouped_field.label}") do |_org_request, answers|
                  if answers
                    answers.values[i].value.map { |x| x[j].value }.min
                  end
                end

                result << Reports::SurveyRequestData::Column.new("Max #{grouped_field.label}") do |_org_request, answers|
                  if answers
                    answers.values[i].value.map { |x| x[j].value }.max
                  end
                end

                result << Reports::SurveyRequestData::Column.new("Avg #{grouped_field.label}") do |_org_request, answers|
                  if answers
                    responses = answers.values[i].value.map { |x| x[j].value }
                    (responses.sum.to_f / responses.size.to_f).round(2)
                  end
                end

                result << Reports::SurveyRequestData::Column.new("Total #{grouped_field.label}") do |_org_request, answers|
                  if answers
                    answers.values[i].value.map { |x| x[j].value }.sum
                  end
                end
              end
            end
          end
        end
      end
    end

    def each
      survey_request.survey_organization_requests.each do |org_request|
        yield Reports::SurveyRequestData::Row.new(self, org_request, org_request.survey_answer&.answers)
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
