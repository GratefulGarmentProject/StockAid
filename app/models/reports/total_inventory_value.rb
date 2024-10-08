module Reports
  module TotalInventoryValue
    def self.new(params, _session)
      if params[:category_id].present?
        Reports::TotalInventoryValue::SingleCategory.new(params)
      else
        Reports::TotalInventoryValue::AllCategories.new(params)
      end
    end

    module Common
      attr_reader :total_value

      def date
        return if @params[:date].blank?
        Time.strptime(@params[:date], "%m/%d/%Y").end_of_day
      end
    end

    class SingleCategory
      include Common
      attr_reader :category

      def initialize(params)
        @category = Category.find(params[:category_id])
        @params = params
      end

      def each
        @total_value = 0.0

        category.items.order(:description).each do |item|
          value = item.total_value(at: date)
          @total_value += value
          yield item.description, value
        end
      end
    end

    class AllCategories
      include Common
      attr_reader :categories

      def initialize(params)
        @categories = Category.all
        @params = params
      end

      def each
        @total_value = 0.0

        categories.includes(:items).find_each do |category|
          value = category.value(at: date)
          @total_value += value
          yield category.description, value
        end
      end
    end
  end
end
