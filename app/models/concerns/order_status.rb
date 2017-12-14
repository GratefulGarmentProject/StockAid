module OrderStatus # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern
  included do
    # Order processing flowchart
    # select_items -> select_ship_to -> confirm_order -/
    # ,----------------------------------------------~'
    # `-> pending -> approved -> filled -> shipped -> received -> closed
    #            `-> rejected

    enum status: { select_items: -3,
                   select_ship_to: -2,
                   confirm_order: -1,
                   pending: 0,
                   approved: 1,
                   rejected: 2,
                   filled: 3,
                   shipped: 4,
                   received: 5,
                   closed: 6,
                   canceled: 7 } do
      event :confirm_items do
        transition select_items: :select_ship_to
      end

      event :edit_items do
        transition [:select_ship_to, :confirm_order] => :select_items
      end

      event :edit_ship_to do
        transition [:confirm_order, :approved, :pending] => :select_ship_to
      end

      event :confirm_ship_to do
        transition select_ship_to: :confirm_order

        after do
          order_details.each { |od| od.destroy! if od.quantity == 0 }
        end
      end

      event :submit_order do
        transition confirm_order: :pending

        after do
          order_details.each do |order_detail|
            order_detail.requested_quantity = order_detail.quantity
          end
        end
      end

      event :approve do
        transition pending: :approved
      end

      event :reject do
        transition pending: :rejected

        after do
          OrderMailer.order_denied(self, @params[:email][:reason]).deliver_now
        end
      end

      event :hold do
        transition [:approved, :rejected] => :pending
      end

      event :allocate do
        transition approved: :filled
      end

      event :ship do
        transition filled: :shipped

        after do
          raise "Require non-new record" if new_record?

          order_details.each do |order_detail|
            item = order_detail.item
            item.mark_event(edit_amount: order_detail.quantity,
                            edit_method: "subtract",
                            edit_reason: "order_adjustment",
                            edit_source: "Order ##{id}")
            item.save!
          end
        end
      end

      event :receive do
        transition shipped: :received
      end

      event :close do
        transition received: :closed
      end

      event :cancel do
        transition all - [:canceled, :rejected] => :canceled

        after do
          case status
          when "select_items", "select_ship_to", "confirm_order", "pending", "approved", "rejected", "filled"

          when "shipped", "received", "closed"
            order_details.each do |order_detail|
              item = order_detail.item
              item.mark_event(edit_amount: order_detail.quantity,
                              edit_method: "add",
                              edit_reason: "order_canceled_adjustment",
                              edit_source: "Order ##{id}")
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

  APPROVED_STATUSES = %w(approved filled shipped received closed canceled).map(&:freeze).freeze
  REQUESTED_STATUSES = %w(pending approved filled).map(&:freeze).freeze
  OPEN_STATUSES = %w(select_items select_ship_to confirm_order pending approved filled shipped received)
                  .map(&:freeze).freeze

  def in_approved_status?
    APPROVED_STATUSES.include?(status)
  end

  def in_requested_status?
    REQUESTED_STATUSES.include?(status)
  end

  class_methods do
    def for_status(status)
      where(status: status)
    end

    def for_approved_statuses
      for_status(approved_statuses)
    end

    def for_requested_statuses
      for_status(requested_statuses)
    end

    def approved_statuses
      @approved_statuses ||= APPROVED_STATUSES.map { |x| statuses[x] }.freeze
    end

    def requested_statuses
      @requested_statuses ||= REQUESTED_STATUSES.map { |x| statuses[x] }.freeze
    end

    def open_statuses
      @open_statuses ||= OPEN_STATUSES.map { |x| statuses[x] }.freeze
    end
  end
end
