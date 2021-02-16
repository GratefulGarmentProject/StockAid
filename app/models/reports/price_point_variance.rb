module Reports
  module PricePointVariance
    attr_accessor :params, :start_date, :end_date

    def self.new(params, session)
      filter = Reports::Filter.new(session)

        Reports::PricePointVariance::AllOrganizations.new(filter)

    def initialize(params, _session)
      @params = params
    end

    def start_date
      @start_date ||= Time.strptime(params[:start_date], "%m/%d/%Y").beginning_of_day
    end

    def end_date
      @end_date ||= Time.strptime(params[:end_date], "%m/%d/%Y").end_of_day
    end

    def each
      Purchases.where('purchase_date >= ? AND purchase_date <= ?', start_date, end_date) do |purchase|
        yield Reports::PricePointVariance::Row.new(purchase)
      end
    end

    class Row
      attr_reader :purchase
      delegate :item, to: :purchase
      delegate :description, to: :item, prefix: true

      def initialize(purchase)
        @purchase = purchase
      end

      def date
        purchase.created_at
      end

      def edit_description
        purchase.edit_source
      end

      def reason
        purchase.edit_reason.capitalize
      end

      def value
        @value ||= purchase.reify.value
      end

      def amount
        @amount ||=
          case purchase.edit_method
          when "add"
            purchase.edit_amount
          when "subtract"
            -purchase.edit_amount
          else
            changed_amount
          end
      end

      def total_value
        amount * value
      end

      private

      def final_count
        version.changeset["current_quantity"].last
      end

      def current_quantity
        version.changeset["current_quantity"].first
      end

      def changed_amount
        return (final_count - current_quantity) unless final_count.nil? || current_quantity.nil?
        raise "Could not determine changed amount for version: #{version.id}"
      end
    end
  end
end
