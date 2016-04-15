module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error
      "alert-danger"
    when :alert, :notice
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
end
