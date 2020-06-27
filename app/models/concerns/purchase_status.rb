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

        # NOTE: From 2020-04-27 status meeting: inventory should be updated when a shipment is received.
      end

      event :complete_purchase do
        transition received: :closed
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
            purchase_details.each do |pd|
              pd.purchase_shipments.each(&:subtract_from_inventory)
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

  OPEN_STATUSES = %w[purchased shipped received].freeze

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
