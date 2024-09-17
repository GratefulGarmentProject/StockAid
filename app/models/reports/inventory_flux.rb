module Reports
  class InventoryFlux
    attr_reader :params

    def initialize(params, session)
      @params = params
      @session = session
      @filter = Reports::Filter.new(session)
    end

    def categories
      @categories ||=
        if params[:category_id].present?
          [Category.find(params[:category_id])]
        else
          Category.all
        end
    end

    def too_broad?
      params[:category_id].blank? &&
        params[:item_id].blank? &&
        params[:report_start_date].blank? &&
        params[:report_end_date].blank?
    end

    def each
    end
  end
end
