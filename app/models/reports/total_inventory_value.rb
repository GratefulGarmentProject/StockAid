module Reports
  module TotalInventoryValue
    def self.new(params, _session)
      if params[:category_id].present?
        Reports::TotalInventoryValue::SingleCategory.new(params)
      else
        Reports::TotalInventoryValue::AllCategories.new
      end
    end

    class SingleCategory
      attr_reader :category

      def initialize(params)
        @category = Category.find(params[:category_id])
      end

      def each
        category.items.order(:description).each do |item|
          yield item.description, item.total_value
        end
      end

      def total_value
        category.value
      end
    end

    class AllCategories
      attr_reader :categories

      def initialize
        @categories = Category.all
      end

      def each
        categories.each do |category|
          yield category.description, category.value
        end
      end

      def total_value
        categories.to_a.sum(&:value)
      end
    end
  end
end
