module ProgramsHelper
  def build_error_content
    content_tag :div do
      content_tag :p, "#{pluralize(record.errors.count, "error")} prohibited this #{record.class.name.downcase} from being saved"

      content_tag :ul do
        record.errors.full_messages.each do |message|
          content_tag :li, message
        end
      end
    end
  end
end
