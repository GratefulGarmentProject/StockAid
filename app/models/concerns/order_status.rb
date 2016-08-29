module OrderStatus
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
                   closed: 6 } do
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
      end

      event :submit_order do
        transition confirm_order: :pending
      end

      event :approve do
        transition pending: :approved
      end

      event :reject do
        transition pending: :rejected
      end

      event :hold do
        transition [:approved, :rejected] => :pending
        transition shipped: :filled
      end

      event :allocate do
        # TODO: allocate the orders detail items here.
        # Order.transaction do
        #   self.allocate_items
        # end

        transition approved: :filled
      end

      event :ship do
        transition filled: :shipped
      end

      event :receive do
        transition shipped: :received
      end

      event :close do
        transition [:rejected, :received] => :closed

        after do
          order_details.each do |order_detail|
            item = order_detail.item
            item.current_quantity -= order_detail.quantity
            item.save!
          end
        end
      end
    end
  end

  def update_status(status)
    return if status.blank?
    return if self.status == status
    send(status)
  end

  class_methods do
    def for_status(status)
      where(status: status)
    end

    def for_requested_statuses
      for_status(requested_statuses)
    end

    def requested_statuses
      @requested_statuses ||= %i(pending approved rejected filled).map { |x| statuses[x] }
    end
  end
end
