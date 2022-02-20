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
      def start_date
        return if @params[:start_date].blank?
        Date.strptime(@params[:start_date], "%m/%d/%Y")
      end

      def end_date
        return if @params[:end_date].blank?
        Date.strptime(@params[:end_date], "%m/%d/%Y")
      end

      def get_purchases(item)
        Purchase.includes(:purchase_details)
                .where(purchase_details: { item_id: item.id })
                .where(purchase_date: start_date..end_date)
      end
    end

    class SingleCategory
      include Common
      attr_accessor :category, :total_value

      def initialize(params)
        @category = Category.find(params[:category_id])
        @params = params
        @total_value = 0.0
      end

      def each
        category.items_including_deleted_after(start_date).order(:description).each do |item|
          @total_value += (item_total_value = item.total_value(at: end_date.end_of_day))
          total_item_ppv = get_purchases(item).map(&:total_ppv).sum

          yield category.description,
                item.description,
                item.total_count(at: end_date.end_of_day),
                item_total_value,
                total_item_ppv
        end
      end
    end

    class AllCategories
      include Common
      attr_accessor :categories, :total_value

      def initialize(params)
        @categories = Category.all
        @params = params
        @total_value = 0.0
        calculate_total_value
      end

      def calculate_total_value
        @total_value = categories.map do |category|
          category.value(at: end_date.end_of_day, unscoped: true)
        end.sum
      end

      def each
        categories.each do |category|
          total_category_ppv = category.items_including_deleted_after(start_date)
                                       .map { |item| get_purchases(item).map(&:total_ppv).sum }
                                       .sum
          total_category_value = category.value(at: end_date.end_of_day, unscoped: true)

          yield category.description,
                nil,
                category.total_count(at: end_date.end_of_day),
                total_category_value,
                total_category_ppv
        end
      end
    end
  end
end
