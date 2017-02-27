class OrderMailer < ApplicationMailer
  def order_denied(order, reason)
    @order = order
    @reason = reason
    mail to: order.user.email,
         subject: "#{Rails.application.config.site_name} - Your order for #{order.organization.name} has been declined."
  end
end
