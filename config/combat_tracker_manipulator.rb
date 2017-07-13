module Users
  module CombatTrackerManipulator
    extend ActiveSupport::Concern

    def can_edit_tracker?(ct)
      id == ct.user_id
    end
  end
end
