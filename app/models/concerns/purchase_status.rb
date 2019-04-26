module PurchaseStatus # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern
  included do
    # Purchase processing flowchart
    # select_items -> select_ship_to -> confirm_order -/
    # ,----------------------------------------------~'
    # `-> order_placed -> shipped -> receiving -> closed

    enum status: { select_items: -3,
                   select_ship_to: -2,
                   confirm_order: -1,
                   order_placed: 0,
                   shipped: 1,
                   receiving: 2,
                   closed: 3,
                   canceled: 4 } do
      event :confirm_items do
        transition select_items: :select_ship_to
      end

      event :edit_items do
        transition [:select_ship_to, :confirm_order] => :select_items
      end

      event :edit_ship_to do
        transition [:confirm_order, :order_placed] => :select_ship_to
      end

      event :confirm_ship_to do
        transition select_ship_to: :confirm_order
      end

      event :submit_purchase do
        transition confirm_order: :order_placed
      end

      event :ship do
        transition order_placed: :shipped
      end

      event :receive do
        transition shipped: :receiving
      end

      event :close do
        transition receiving: :closed
      end

      event :cancel do
        old_status = ""

        before do
          old_status = status
        end

        transition all - [:canceled, :rejected] => :canceled

        after do
          case old_status
          when "receiving", "closed"
            # 'return if dropship?' to be added with dropships
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

  PREPROCESSING_STATUSES = %w(select_items select_ship_to confirm_order).map(&:freeze).freeze
  OPEN_STATUSES = %w(select_items select_ship_to confirm_order order_placed shipped receiving)
                  .map(&:freeze).freeze

  def in_preprocessing?
    PREPROCESSING_STATUSES.include?(status)
  end

  class_methods do
    def for_status(status)
      where(status: status)
    end

    # def for_approved_statuses
    #   for_status(approved_statuses)
    # end

    # def for_requested_statuses
    #   for_status(requested_statuses)
    # end

    # def approved_statuses
    #   @approved_statuses ||= APPROVED_STATUSES.map { |x| statuses[x] }.freeze
    # end

    # def requested_statuses
    #   @requested_statuses ||= REQUESTED_STATUSES.map { |x| statuses[x] }.freeze
    # end

    def open_statuses
      @open_statuses ||= OPEN_STATUSES.map { |x| statuses[x] }.freeze
    end
  end
end
