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
        category.items.order(:description).each do |item|
          yield item.description, item.total_value(at: date)
        end
      end

      def total_value
        category.value
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
        categories.each do |category|
          yield category.description, category.value(at: date)
        end
      end

      def total_value
        categories.to_a.sum(&:value)
      end
    end
  end
end
