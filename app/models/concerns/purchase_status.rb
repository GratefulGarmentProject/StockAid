module PurchaseStatus
  extend ActiveSupport::Concern
  included do # rubocop:disable Metrics/BlockLength
    # Purchase processing flowchart
    #   new_purchase ---\
    #    /--------------/
    #    \---> purchased -> shipped -> received --\
    #    /----------------------------------------/
    #    \---> closed
    #

    enum status: { new_purchase: -1, # rubocop:disable Metrics/BlockLength
                   purchased: 0,
                   shipped: 1,
                   received: 2,
                   closed: 3,
                   canceled: 4 } do
      event :place_purchase do
        transition new_purchase: :purchased
      end

      event :ship_purchase do
        transition purchased: :shipped
      end

      event :receive_purchase do
        transition shipped: :received
      end

      event :complete_purchase do
        transition received: :closed
      end

      event :cancel_purchase do
        transition all - [:canceled] => :canceled

        after do
          shipments.each(&:subtract_from_inventory) if shipments.present?
        end
      end
    end
  end

  def update_status(status, params = {})
    return if status.blank?
    return if self.status == status
    @params = params
    send(status)
  end

  OPEN_STATUSES = %w[new_purchase purchased shipped received].freeze
  SHIPMENT_STATUSES = %w[shipped received closed canceled].freeze

  def open_purchase?
    OPEN_STATUSES.include?(status)
  end

  def show_shipments?
    SHIPMENT_STATUSES.include?(status)
  end

  class_methods do
    def for_status(status)
      where(status: status)
    end

    def open_statuses
      @open_statuses ||= OPEN_STATUSES.map { |x| statuses[x] }.freeze
    end
  end
end
