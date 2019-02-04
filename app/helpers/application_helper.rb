module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error
      "alert-danger"
    when :alert, :notice, :warning
      "alert-warning"
    when :info
      "alert-info"
    end
  end

  def confirm(message: "Are you sure?", fade: true, title:)
    {
      confirm: message,
      confirm_fade: fade,
      confirm_title: title
    }
  end

  def tab(label, path, active)
    render partial: "common/tab", locals: { label: label, path: path, active: active }
  end

  def guarded_field(record, field, guards)
    {}.tap do |result|
      result[:guards] = guards if guards.present?

      if record && record.errors.messages[field]
        result[:immediate_guard_error] = "#{field.to_s.humanize.titleize} #{record.errors.messages[field].first}"
      end
    end
  end

  def external_types_for_select
    %w(Individual Organization Company Agency)
  end
end
