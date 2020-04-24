module PurchaseStatus # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern
  included do
    # Purchase processing flowchart
    #   purchase_placed -> shipped -> received -> closed
    #

    enum status: { new_purchase: -1,
                   purchased: 0,
                   shipped: 1,
                   received: 2,
                   closed: 3,
                   canceled: 4 } do

      event :create_purchase do
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

        # populate inventory with items on PO
      end

      event :cancel_purchase do
        old_status = ""

        before do
          old_status = status
        end

        transition all - [:canceled] => :canceled

        after do
          case old_status
          when "received"
            purchase_details.each do |purchase_detail|
              item = purchase_detail.item
              item.mark_event(edit_amount: purchase_detail.quantity,
                              edit_method: "subtract",
                              edit_reason: "purchase_canceled_adjustment",
                              edit_source: "Purchase ##{id}")
              item.save!
            end
          end
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

  OPEN_STATUSES = %w(purchase_placed shipped received).freeze

  def open_purchase?
    OPEN_STATUSES.include?(status)
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
