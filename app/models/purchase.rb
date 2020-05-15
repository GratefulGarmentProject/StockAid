class Purchase < ApplicationRecord
  include PurchaseStatus

  attribute :open_purchase?, :boolean

  belongs_to :user
  belongs_to :vendor
  belongs_to :vendor_unscoped, -> { unscope(:where) }, class_name: "Vendor", foreign_key: :vendor_id

  has_many :purchase_details, autosave: true, dependent: :restrict_with_exception
  has_many :purchase_shipments, through: :purchase_details, dependent: :restrict_with_exception
  has_many :items, through: :purchase_details

  accepts_nested_attributes_for :purchase_details, allow_destroy: true

  before_validation :set_new_status, on: :create
  before_save :prevent_updates_when_closed, on: :update

  validates :user, presence: true
  validates :vendor, presence: true
  validates :po, presence: true
  validates :purchase_date, presence: true
  validates :status, presence: true

  def self.for_vendor(vendor)
    where(vendor: vendor)
  end

  def formatted_purchase_date
    purchase_date&.strftime("%-m/%-d/%Y")
  end

  def cost
    purchase_details.map(&:line_cost).sum
  end

  def item_count
    purchase_details.map(&:quantity).sum
  end

  def serialize_data_for_edit # rubocop:disable Metrics/MethodLength
    as_json(
      include: {
        user: {
          only: [:id, :name, :role]
        },
        vendor: {
          only: [:id, :name, :phone_number, :website, :email, :contact_name]
        },
        purchase_details: {
          include: {
            item: {
              only: [:id, :description, :current_quantity, :value],
              include: {
                category: {
                  only: [:id, :description]
                }
              }
            },
            purchase_shipments: {
              only: [:id, :quantity_received, :received_date]
            }
          }
        }
      }
    )
  end

  private

  def prevent_updates_when_closed
    return unless closed? || canceled?
    unless changed.include?("status")
      msg = "Can't modify purchase after it's closed or canceled"
      restore_attributes
      raise msg
    end
  end

  # FIXME: What is this used for? valid_purchase_params isn't defined
  # def skip_adding_purchase_details?
  #   return true if valid_purchase_params.dig(:purchase_details, :item_id).blank?
  #   false
  # end

  def set_new_status
    self.status = :new_purchase if status.blank?
  end
end
