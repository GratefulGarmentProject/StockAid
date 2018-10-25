module ReconciliationsHelper
  def reconciliation_delta_table_row(delta)
    link_to_sheet = inventory_reconciliation_count_sheet_path(delta.reconciliation, delta.warning_count_sheet_id)
    href_data = delta.warning_count_sheet_id ? { href: link_to_sheet } : {}
    data = { toggle: "tooltip", placement: "top", title: delta.warning_text }.merge(href_data)
    tag(:tr, class: delta.row_css_class, data: data)
  end
end
