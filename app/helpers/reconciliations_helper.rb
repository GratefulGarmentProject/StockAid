module ReconciliationsHelper
  def reconciliation_delta_table_row(delta, &block)
    data = { toggle: "tooltip", placement: "top", title: delta.warning_text }

    data[:href] = inventory_reconciliation_count_sheet_path(delta.reconciliation, delta.warning_count_sheet_id) if delta.warning_count_sheet_id

    content_tag(:tr, class: delta.row_css_class, data: data, &block)
  end

  def changed_amount_icon(delta)
    return unless delta.changed_amount?

    if delta.changed_amount > 0
      content_tag(:i, "", class: "glyphicon glyphicon-triangle-top")
    else
      content_tag(:i, "", class: "glyphicon glyphicon-triangle-bottom")
    end
  end
end
