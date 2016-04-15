module Users
  module OrderManipulator
    extend ActiveSupport::Concern

    def can_create_order_at?(organization)
      super_admin? || member_at?(organization)
    end

    def create_order(params)
      transaction do
        organization = Organization.find(params[:order][:organization_id])
        raise PermissionError unless can_create_order_at?(organization)
        order = Order.new(organization: organization,
                          user: self,
                          order_date: Time.zone.now,
                          status: :select_ship_to,
                          ship_to_name: name)
        order.add_details(params)
        order.save!
        order
      end
    end
  end
end
