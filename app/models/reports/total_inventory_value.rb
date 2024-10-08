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
      include CsvExport
      attr_reader :total_value

      def date
        return if @params[:date].blank?
        @date ||= Time.strptime(@params[:date], "%m/%d/%Y").end_of_day
      end

      def csv_filename
        date_part = "_#{date.strftime('%m-%d-%Y')}" if date
        "total-inventory-value_#{csv_filename_scope}#{date_part}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
      end

      def csv_export_row(row)
        row
      end

      def each_csv_row
        each do |description, value|
          yield([description, value])
        end
      end
    end

    class SingleCategory
      include Common
      attr_reader :category
      FIELDS = %w[Item Value]

      def initialize(params)
        @category = Category.find(params[:category_id])
        @params = params
      end

      def csv_filename_scope
        category.description.gsub(/[^a-zA-Z0-9_]/, "_").gsub(/_+/, "_")
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
      FIELDS = %w[Category Value]

      def initialize(params)
        @categories = Category.all
        @params = params
      end

      def csv_filename_scope
        "All_Categories"
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
