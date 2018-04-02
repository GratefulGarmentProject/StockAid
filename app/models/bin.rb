class Bin < ActiveRecord::Base
  belongs_to :bin_location
  has_many :bin_items
  has_many :items, -> { order(:description) }, through: :bin_items

  def self.create_bin!(params)
    transaction do
      bin_location = BinLocation.create_or_find_bin_location(params)
      label = Bin.generate_label(params)
      item_ids = params.require(:bin_items).require(:item_id)

      Bin.create! do |bin|
        bin.bin_location = bin_location
        bin.label = label

        Item.where(id: item_ids).find_each do |item|
          bin.bin_items.build(item: item)
        end
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
end
