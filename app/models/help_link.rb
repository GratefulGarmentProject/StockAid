class HelpLink < ApplicationRecord
  def self.for_users
    where(visible: true).order(ordering: :asc)
  end

  def self.for_editing
    order(ordering: :asc)
  end

  def decrement_ordering
    self.ordering = ordering - 1
    save!
  end

  def increment_ordering
    self.ordering = ordering + 1
    save!
  end

  def move_up
    previous_ordering = HelpLink.where("ordering < ?", ordering).maximum(:ordering)
    return unless previous_ordering
    HelpLink.where("ordering > ?", ordering).order(ordering: :desc).to_a.each(&:increment_ordering)
    link = HelpLink.find_by(ordering: previous_ordering)
    link.ordering = ordering + 1
    link.save!
  end

  def move_down
    next_ordering = HelpLink.where("ordering > ?", ordering).minimum(:ordering)
    return unless next_ordering
    HelpLink.where("ordering < ?", ordering).order(ordering: :asc).to_a.each(&:decrement_ordering)
    link = HelpLink.find_by(ordering: next_ordering)
    link.ordering = ordering - 1
    link.save!
  end

  def visibility_icon
    if visible
      "eye-open"
    else
      "eye-close"
    end
  end
end
