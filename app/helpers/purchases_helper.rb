module PurchasesHelper
  def cancel_edit_purchase_path
    Redirect.to(purchases_path, params, allow: :purchases)
  end

  def cancel_new_purchase_path
    Redirect.to(purchases_path, params, allow: :purchases)
  end

  def purchase_detail_quantity_class(purchase_detail)
    if purchase_detail.quantity == purchase_detail.requested_quantity
      "same-quantity"
    elsif purchase_detail.quantity > purchase_detail.requested_quantity
      "different-quantity more-quantity"
    else
      "different-quantity less-quantity"
    end
  end

  def vendor_options
    Vendor.active.order("LOWER(name)").map do |vendor|
      [vendor.name, vendor.id, {
        "data-name" => vendor.name,
        "data-phone-number" => vendor.phone_number,
        "data-website" => vendor.website,
        "data-email" => vendor.email,
        "data-contact-name" => vendor.contact_name,
        "data-search-text" => vendor.data_search_text
      }]
    end
  end

  def purchase_row_item_options(purchase_detail)
    return [] if purchase_detail.item.blank?
    items_for_options = Item.where(category: purchase_detail.item.category)
    options = items_for_options.map { |i| [i.description, i.id, { "data-item-value" => i.value }] }
    options_for_select(options, purchase_detail.item.id)
  end

  def link_to_add_purchase_shipment_fields(purchase_detail_form)
    association = :purchase_shipments
    new_object = purchase_detail_form.object.send(association).klass.new
    id = new_object.object_id
    fields = purchase_detail_form.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", ps: new_object, ps_f: builder)
    end

    link_to "#", data: { id: id, fields: fields.delete("\n") },
                 class: "btn btn-sm btn-default add-#{association.to_s.singularize.tr('_', '-')}-fields" do
      yield
    end
  end

  # This method creates a link with `data-id` `data-fields` attributes.
  # These attributes are used to create new instances of the nested fields through Javascript.
  def link_to_add_purchase_detail_fields(purchase_form)
    association = :purchase_details
    new_object = purchase_form.object.send(association).klass.new
    id = new_object.object_id
    fields = purchase_form.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", pd: new_object, pd_f: builder)
    end

    link_to "#", data: { id: id, fields: fields.delete("\n") },
                 class: "btn btn-default add-#{association.to_s.singularize.tr('_', '-')}-fields" do
      yield
    end
  end

  def link_to_remove_purchase_shipment_row(ps)
    if ps.persisted?
      link_to purchase_shipment_path(id: ps.id), build_delete_options(ps) do
        shared_delete_content
      end
    else
      button_tag build_delete_options(ps) do
        shared_delete_content
      end
    end
  end

  private

  def build_delete_options(ps)
    return shared_delete_options(ps).merge(persisted_deleted_options) if ps.persisted?
    shared_delete_options(ps).merge(non_persisted_deleted_options)
  end

  def shared_delete_options(ps)
    { title: "Delete this shipment record",
      data: { confirm: purchase_shipment_confirm(ps),
              confirm_title: "Deleting a shipment",
              confirm_fade: "true" } }
  end

  def persisted_deleted_options
    { remote: true, method: :delete, class: "btn btn-danger" }
  end

  def non_persisted_deleted_options
    { class: "btn btn-danger remove-purchase-shipment-fields" }
  end

  def purchase_shipment_confirm(purchase_shipment)
    return t("purchases.detail_shipment.confirm_cancel_dialog_persisted") if purchase_shipment.persisted?
    t("purchases.detail_shipment.confirm_cancel_dialog")
  end

  def shared_delete_content
    content_tag :span, nil, class: "glyphicon glyphicon-trash"
  end
end
