class PoNumberGenerator
  attr_reader :vendor

  def initialize(vendor_id)
    @vendor = Vendor.find_by(id: vendor_id)
  end

  def generate
    return format_string("UNKNOWN", 0) unless vendor.present?

    prefix = vendor.name.parameterize
    number_part = find_last_po_number + 1
    number_part += 1 while next_po_exist?(format_string(prefix, number_part))
    format_string(prefix, number_part)
  end

  def clean_prefix(s)
    s.upcase.gsub(/[^[:alnum:]]/, "").slice(0..5)
  end

  def format_string(prefix, number)
    "#{format('%-6s', clean_prefix(prefix))}-#{format('%06d', number)}"
  end

  def find_last_po_number
    Purchase
      .where(vendor: vendor)
      .maximum(:po)
      .to_s
      .split(/[^\d]+/)
      .last
      .to_i
  end

  def next_po_exist?(next_po)
    Purchase.find_by(po: next_po)
  end
end
