module Users
  module ReportManipulator
    extend ActiveSupport::Concern

    def can_view_reports?
      super_admin?
    end
  end
end
