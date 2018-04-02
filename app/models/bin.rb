require "set"

class Bin < ActiveRecord::Base
  belongs_to :bin_location
  has_many :bin_items
  has_many :items, -> { order(:description) }, through: :bin_items

  def build_items(params)
    item_ids = params.require(:bin_items).require(:item_id).map(&:to_i)
    item_ids -= bin_items.map(&:item_id)

    Item.where(id: item_ids).find_each do |item|
      bin_items.build(item: item)
    end
  end

  def delete_items!(params)
    item_ids = params.require(:bin_items).require(:item_id).map(&:to_i)
    item_ids = Set.new(bin_items.map(&:item_id) - item_ids)

    bin_items.each do |bin_item|
      bin_item.destroy! if item_ids.include?(bin_item.item_id)
    end
  end

  def self.update_bin!(params)
    transaction do
      bin = Bin.find(params[:id])
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

    Bin.where("label LIKE ?", "#{prefix}%").find_each do |bin|
      next unless bin.label =~ pattern
      value = bin.label[/\d+/].to_i
      max_existing = value if value > max_existing
    end

    "#{prefix}#{max_existing + 1}"
  end

  def label_prefix
    label[/\A(.*?)\d*\z/, 1]
  end

  def label_suffix
    label[/(\d+)\z/, 1]
  end
end
