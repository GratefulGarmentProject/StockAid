module ReconciliationsHelper
  def reconciliation_delta_table_row(delta)
    data = { toggle: "tooltip", placement: "top", title: delta.warning_text }

    if delta.warning_count_sheet_id
      data[:href] = inventory_reconciliation_count_sheet_path(delta.reconciliation, delta.warning_count_sheet_id)
    end

    content_tag(:tr, class: delta.row_css_class, data: data) do
      yield
    end
  end

  def changed_amount_icon(delta)
    return unless delta.changed_amount?

    if delta.changed_amount > 0
      tag(:i, class: "glyphicon glyphicon-triangle-top")
    else
      tag(:i, class: "glyphicon glyphicon-triangle-bottom")
    end
  end
end
