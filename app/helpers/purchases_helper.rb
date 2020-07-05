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
    items_for_options = Item.where(category: purchase_detail.item.category).pluck(:description, :id)
    options_for_select(items_for_options, purchase_detail.item.id)
  end

  # This method creates a link with `data-id` `data-fields` attributes. These attributes are used to create new instances of the nested fields through Javascript.
  def link_to_add_fields(f, association)
    # Takes an object (@purchase) and creates a new instance of its associated model (:purchase_details)
    new_object = f.object.send(association).klass.new

    # Saves the unique ID of the object into a variable.
    # This is needed to ensure the key of the associated array is unique. This is makes parsing the content in the `data-fields` attribute easier through Javascript.
    # We could use another method to achive this.
    id = new_object.object_id

    # https://api.rubyonrails.org/ fields_for(record_name, record_object = nil, fields_options = {}, &block)
    # record_name = :purchase_details
    # record_object = new_object
    # fields_options = { child_index: id }
    # child_index` is used to ensure the key of the associated array is unique, and that it matched the value in the `data-id` attribute.
    # `purchase[purchase_details_attributes][child_index_value][<field_name>]`
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      # `association.to_s.singularize + "_fields"` ends up evaluating to `purchase_detail_fields`
      # The render function will then look for `views/purchases/_purchase_detail_fields.html.erb`
      # The render function also needs to be passed the value of 'builder', because `views/purchases/_purchase_detail_fields.html.erb` needs this to render the form tags.
      render(association.to_s.singularize + "_fields", pd: new_object, pd_f: builder)
    end

    # This renders a simple link, but passes information into `data` attributes.
    # This info can be named anything we want, but in this case we chose `data-id:` and `data-fields:`.
    # The `id:` is from `new_object.object_id`.
    # The `fields:` are rendered from the `fields` blocks.
    # We use `gsub("\n", "")` to remove anywhite space from the rendered partial.
    # The `id:` value needs to match the value used in `child_index: id`.
    link_to "#", class: "add-#{association.to_s.singularize.gsub("_", "-") { |match|  }}-fields", data: { id: id, fields: fields.delete("\n") } do
      yield
    end
  end
end
