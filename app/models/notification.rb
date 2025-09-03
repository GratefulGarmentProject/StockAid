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
end
