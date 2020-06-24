module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deleted_at: nil) }
    scope :deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
    scope :not_deleted, -> { unscope(where: :deleted_at).where(deleted_at: nil) }
    scope :find_deleted, ->(id) { deleted.find(id) }
  end

  def soft_deleted?
    deleted_at.present?
  end

  def soft_delete
    self.deleted_at = Time.zone.now
    save!
  end

  def restore
    self.deleted_at = nil
    save!
  end
end
