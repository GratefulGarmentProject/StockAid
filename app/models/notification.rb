# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true
  belongs_to :triggered_by_user, class_name: "User", optional: true

  # Notification types
  SPOILAGE = "spoilage"
  DELETED_DONATIONS = "deleted_donations"
  DELETED_PURCHASES = "deleted_purchases"

  SUBSCRIPTION_TYPES = {
    spoilage: {
      type: SPOILAGE,
      label: "Notify me when spoilages are added"
    }.freeze,
    deleted_donations: {
      type: DELETED_DONATIONS,
      label: "Notify me when donations are deleted"
    }.freeze,
    deleted_purchases: {
      type: DELETED_PURCHASES,
      label: "Notify me when purchases are deleted"
    }.freeze
  }.freeze

  def self.notify_spoilage(current_user, item, params)
    return unless params[:edit_amount] && params[:edit_method] && params[:edit_reason]
    return unless params[:edit_reason] == "spoilage"

    notify!(Notification::SPOILAGE, title: "Spoilage for item #{item.description}", message: <<~MESSAGE, triggered_by_user: current_user, reference: item)
      Spoilage update for item ##{item.id} (#{item.category.description} - #{item.description}):

      Stock #{params[:edit_method]} by #{params[:edit_amount]}.

      Reason: #{params[:edit_source]}
    MESSAGE
  end

  def self.notify!(type, title:, message:, triggered_by_user: nil, reference: nil)
    caught_error = nil

    NotificationSubscription.includes(:user).where(notification_type: type, enabled: true).find_each do |subscription|
      begin
        next unless subscription.user.can_subscribe_to_notifications?(type)

        create!(title: title, message: message, user: subscription.user, triggered_by_user: triggered_by_user, reference: reference)
      rescue StandardError => e
        caught_error = e
      end
    end

    raise caught_error if caught_error
  end

  def unread?
    completed_at.blank?
  end

  def read?
    completed_at.present?
  end
end
