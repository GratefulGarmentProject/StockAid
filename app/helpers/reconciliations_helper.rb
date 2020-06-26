module ReconciliationsHelper
  def delta_table_row_data(delta)
    data = { toggle: "tooltip", placement: "top", title: delta.warning_text }

    if delta.warning_count_sheet_id
      data[:href] = inventory_reconciliation_count_sheet_path(delta.reconciliation, delta.warning_count_sheet_id)
    end

    data
  end

  def changed_amount_icon_class(delta)
    return unless delta.changed_amount?

    if delta.changed_amount > 0
      "glyphicon glyphicon-triangle-top"
    else
      "glyphicon glyphicon-triangle-bottom"
    end
  end

  def description_css_class(delta)
    return unless delta.changed_amount?

    if delta.changed_amount > 0
      "text-bold text-success"
    else
      "text-bold text-danger"
    end
  end

  def changed_amount_css_class(delta)
    return unless delta.changed_amount?

    if delta.changed_amount > 0
      "text-success"
    else
      "text-danger"
    end
  end

  def row_css_class(delta)
    if delta.error?
      "danger"
    elsif delta.warning?
      "warning"
    end
  end
end
