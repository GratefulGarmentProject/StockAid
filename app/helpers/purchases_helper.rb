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

  def sync_purchase_button(purchase)
    css_class = "btn btn-primary"

    css_class += " disabled" unless purchase.vendor.synced?

    button = link_to "Sync to NetSuite",
                     sync_purchase_path(purchase),
                     class: css_class,
                     data: { toggle: "tooltip" },
                     method: :post

    if purchase.vendor.synced?
      button
    else
      disabled_title_wrapper("Please sync the vendor to be able to sync to NetSuite.") { button }
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

  # This method creates a link with `data-id` `data-fields` attributes.
  # These attributes are used to create new instances of the nested fields through Javascript.
  def link_to_add_association_fields(form, association_name)
    # build a new associated object
    new_object = form.object.send(association_name).klass.new
    # Get objects unique ruby id to use in the construction of fields as index
    ruby_obj_id = new_object.object_id

    fields = form.fields_for(association_name, new_object, child_index: ruby_obj_id) do |builder|
      render(association_name.to_s.singularize + "_fields", record: new_object, form: builder)
    end

    link_to "#", data: { ruby_obj_id: ruby_obj_id, fields: fields.delete("\n") },
                 class: "btn btn-default add-#{association_name.to_s.singularize.tr('_', '-')}-fields" do
      yield
    end
  end

  def link_to_remove_purchase_association_row(record)
    type = record.class.name.underscore.split("_").last
    # New (non saved) PurchaseDetail or PurchaseShipment
    return non_persisted_delete_button(type) unless record.persisted?
    # Persisted (saved) PurchaseDetail with saved PurchaseShipment(s)
    return purchase_detail_with_shipments_delete_button if shipments?(record)
    # Persisted (saved) PurchaseDetail or PurchaseShipment that can be deleted
    persisted_delete_button(record, type)
  end

  private

  def non_persisted_delete_button(type)
    button_tag non_persisted_deleted_options(type).merge(shared_delete_options(type)) do
      shared_delete_content
    end
  end

  def non_persisted_deleted_options(type)
    { type: :button, class: "btn btn-danger remove-purchase-#{type}-fields" }
  end

  def shared_delete_options(type)
    { title: "Delete this #{type} record" }
  end

  def purchase_detail_with_shipments_delete_button
    button_tag title: "Disabled: Shipments exist!", class: "btn btn-danger", disabled: true do
      shared_delete_content
    end
  end

  def persisted_delete_button(record, type)
    link_to send("purchase_#{type}_path", id: record.id), persisted_deleted_options(record, type) do
      shared_delete_content
    end
  end

  def persisted_deleted_options(record, type)
    shared_delete_options(type).merge(
      remote: true, method: :delete, class: "btn btn-danger",
      data: { confirm: send("purchase_#{type}_confirm", record),
              confirm_title: "Deleting a #{type}", confirm_fade: "true" }
    )
  end

  def purchase_detail_confirm(_)
    t("purchase.detail.confirm_delete_dialog")
  end

  def purchase_shipment_confirm(purchase_shipment)
    if purchase_shipment.persisted?
      t("purchase.shipment.confirm_delete_dialog_persisted")
    else
      t("purchase.shipment.confirm_delete_dialog")
    end
  end

  def shipments?(record)
    record.respond_to?(:purchase_shipments) && record.purchase_shipments.present?
  end

  def shared_delete_content
    content_tag :span, nil, class: "glyphicon glyphicon-trash"
  end
end
