class Order < ApplicationRecord
  belongs_to :organization
  belongs_to :organization_unscoped, -> { unscope(where: :deleted_at) },
             class_name: "Organization",
             foreign_key: :organization_id
  belongs_to :user
  has_many :order_details, autosave: true
  has_many :order_program_details, autosave: true
  has_many :items, through: :order_details
  has_many :tracking_details
  has_many :survey_answers

  include OrderStatus

  def self.by_status_includes_extras(statuses, include_tables = %i[organization order_details tracking_details])
    statuses = [statuses].flatten.map { |s| Order.statuses[s] }
    includes(*include_tables).where(status: statuses)
  end

  def required_surveys
    @required_surveys ||=
      items.map do |item|
        item.programs.map do |program|
          program.surveys.to_a
        end
      end.flatten.uniq.sort_by(&:title)
  end

  def requires_survey_answers?
    required_surveys.present?
  end

  def unscoped_organization
    @unscoped_organization ||= Organization.unscoped.find(organization_id)
  end

  def add_tracking_details(params)
    params[:order][:tracking_details][:tracking_number].each_with_index do |tracking_number, index|
      shipping_carrier = params[:order][:tracking_details][:shipping_carrier][index]
      tracking_details.build(
        date: Time.zone.now,
        tracking_number: tracking_number,
        shipping_carrier: shipping_carrier.to_i
      )
    end
  end

  def sync_status_available?
    external_id.present?
  end

  def synced?
    external_id.present? && !NetSuiteIntegration.export_failed?(self)
  end

  def formatted_order_date
    order_date.strftime("%-m/%-d/%Y") if order_date.present?
  end

  def submitted?
    !select_items? && !select_ship_to? && !confirm_order?
  end

  def open?
    !(closed? || rejected? || canceled?)
  end

  def order_uneditable?
    filled? || shipped? || received? || closed? || rejected? || canceled?
  end

  def ship_to_addresses
    organization.addresses.map(&:address)
  end

  def ship_to_names
    [user.name.to_s, "#{organization.name} c/o #{user.name}"]
  end

  def organization_ship_to_names
    organization.users.map do |user|
      [user.name.to_s, "#{organization.name} c/o #{user.name}"]
    end.flatten
  end

  def to_json
    {
      id: id,
      status: status,
      order_details: order_details.sort_by(&:id).map(&:to_json),
      in_requested_status: in_requested_status?
    }.to_json
  end

  def self.to_json
    includes(:order_details).order(:id).all.map(&:to_json).to_json
  end

  def value
    order_details.map(&:total_value).sum
  end

  def item_count
    order_details.map(&:quantity).sum
  end

  def create_values_for_programs
    transaction do
      program_values = Hash.new { |h, k| h[k] = 0.0 }

      order_details.each do |detail|
        ratios = detail.item.program_ratio_split_for(organization_unscoped.programs)

        ratios.each do |program, ratio|
          program_values[program] += detail.total_value * ratio
        end
      end

      program_values.each do |program, value|
        order_program_details.create!(program: program, value: value)
      end
    end
  end

  def value_by_program
    order_program_details.all.each_with_object({}) do |detail, result|
      result[detail.program] = detail.value
      result
    end
  end
end
