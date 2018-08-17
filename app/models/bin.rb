require "set"

class Bin < ApplicationRecord
  belongs_to :bin_location
  has_many :bin_items
  has_many :items, -> { order(:description) }, through: :bin_items
  has_many :order_details, through: :items

  def to_json
    {
      id: id,
      label: label,
      location: bin_location.display
    }
  end

  def build_items(params)
    new_item_ids = bin_item_ids(params)
    new_item_ids -= bin_items.map(&:item_id)

    Item.where(id: new_item_ids).find_each do |item|
      bin_items.build(item: item)
    end
  end

  def delete_items!(params)
    item_ids_to_remove = bin_item_ids(params)
    item_ids_to_remove = Set.new(bin_items.map(&:item_id) - item_ids_to_remove)

    bin_items.each do |bin_item|
      bin_item.destroy! if item_ids_to_remove.include?(bin_item.item_id)
    end
  end

  def label_prefix
    label[/\A(.*?)\d*\z/, 1]
  end

  def label_suffix
    label[/(\d+)\z/, 1]
  end

  def rack
    bin_location.rack
  end

  def self.not_deleted
    where(deleted_at: nil)
  end

  def self.for_print_prep
    includes(:bin_location, :items).order(:label)
  end

  def self.to_json
    includes(:bin_location).order(:label).map(&:to_json).to_json
  end

  def self.update_bin!(params)
    transaction do
      bin = Bin.not_deleted.find(params[:id])
      bin.bin_location = BinLocation.create_or_find_bin_location(params)
      bin.label = Bin.generate_label(params)
      bin.delete_items!(params)
      bin.build_items(params)
      bin.save!
    end
  end

  def self.create_bin!(params)
    transaction do
      Bin.create! do |bin|
        bin.bin_location = BinLocation.create_or_find_bin_location(params)
        bin.label = Bin.generate_label(params)
        bin.build_items(params)
      end
    end
  end

  def self.generate_label(params)
    label_params = params.permit(:label_prefix, :label_suffix)
    prefix = label_params[:label_prefix]
    suffix = label_params[:label_suffix]
    raise "Prefix is required!" if prefix.blank?
    return "#{prefix}#{suffix}" if suffix.present?
    next_label_with_prefix(prefix)
  end

  def self.next_label_with_prefix(prefix)
    pattern = /\A#{Regexp.escape(prefix)}\d+\z/
    max_existing = 0

    Bin.not_deleted.where("label LIKE ?", "#{prefix}%").find_each do |bin|
      next unless bin.label =~ pattern
      value = bin.label[/\d+/].to_i
      max_existing = value if value > max_existing
    end

    "#{prefix}#{max_existing + 1}"
  end

  private

  def bin_item_ids(params)
    params.permit(bin_items: { item_id: [] }).fetch(:bin_items, {}).fetch(:item_id, []).map(&:to_i)
  end
end
