module Users
  module ReportManipulator
    extend ActiveSupport::Concern

    def can_edit_help_links?
      super_admin?
    end

    def can_view_reports?
      super_admin? || report_admin?
    end

    def can_export?
      super_admin?
    end
  end
end
