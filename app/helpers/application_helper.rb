module ApplicationHelper
  def help_links
    @help_links ||= HelpLink.for_users.to_a
  end

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

  def disabled_title_wrapper(msg, &block)
    tag.div class: "disabled-title-wrapper", title: msg, data: { toggle: "tooltip" }, &block
  end

  def confirm(title:, message: "Are you sure?", fade: true)
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
    NetSuiteIntegration::Constituent::NETSUITE_TYPES.keys
  end

  def external_id_or_status(object, link: false, prefix: nil)
    external_id = NetSuiteIntegration.external_id_for(object, prefix: prefix)
    return unless external_id

    if NetSuiteIntegration.export_queued?(object, prefix: prefix)
      tag.em { "Export queued" }
    elsif NetSuiteIntegration.export_in_progress?(object, prefix: prefix)
      tag.em { "Export in progress" }
    elsif NetSuiteIntegration.export_failed?(object, prefix: prefix)
      tag.em { tag.strong(class: "text-danger") { "Export failed!" } }
    elsif NetSuiteIntegration.export_not_applicable?(object, prefix: prefix)
      tag.em { "N/A" }
    elsif link
      external_link(object, prefix: prefix)
    else
      external_id
    end
  end

  def external_link(object, prefix: nil)
    external_id = NetSuiteIntegration.external_id_for(object, prefix: prefix)
    return external_id unless Rails.application.config.netsuite_initialized

    path = NetSuiteIntegration.path(object, prefix: prefix)

    if path
      link_to external_id, path
    else
      external_id
    end
  end
end
