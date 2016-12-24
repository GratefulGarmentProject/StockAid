module Reports
  class Filter
    def initialize(session)
      @session = session
    end

    def apply_date_filter(scope, column)
      if filtering_by_date?
        from = Date.strptime(start_date, "%m/%d/%Y").beginning_of_day
        to = Date.strptime(end_date, "%m/%d/%Y").end_of_day
        scope.where(column => (from..to))
      else
        scope
      end
    end

    def filtering_by_date?
      start_date.present? && end_date.present?
    end

    def start_date
      @session[:report_start_date]
    end

    def end_date
      @session[:report_end_date]
    end
  end
end
