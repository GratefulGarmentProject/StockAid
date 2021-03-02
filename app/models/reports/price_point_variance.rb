module Reports
  module PricePointVariance
    attr_accessor :params, :start_date, :end_date

    def self.new(params, session)
      filter = Reports::Filter.new(session)

      if params[:vendor_id].present?
        Reports::PricePointVariance::SingleVendor.new(params, filter)
      else
        Reports::PricePointVariance::AllVendors.new(filter)
      end
    end

    def self.vendors
      Vendor.order(:name)
    end

    module Base
      def each
        data.each { |x| yield(*x) }
      end

      def total_purchase_count
        data.map { |x| x[1] }.sum
      end

      def total_value
        data.map { |x| x[2] }.sum
      end
    end

    class AllVendors
      include Reports::PricePointVariance::Base
      attr_reader :purchases

      def initialize(filter)
        @purchases = filter.apply_date_filter(Purchase.all, :purchase_date)
                           .includes(:vendor, :purchase_details)
                           .to_a.group_by(&:vendor)
      end

      def description_label
        "Vendor"
      end

      def data
        @data ||= purchases.keys.sort.map do |vendor|
          total_ppv = purchases[vendor].map(&:total_ppv).inject(0, :+)
          [vendor.name, total_ppv]
        end
      end
    end

    class SingleVendor
      include Reports::PricePointVariance::Base
      attr_reader :vendor, :purchases

      def initialize(params, filter)
        @vendor = Vendor.find params[:vendor_id]
        @purchases = filter.apply_date_filter(@vendor.purchases, :purchase_date).includes(:purchase_details)
      end

      def description_label
        "Purchase"
      end

      def data
        return [] if purchases.blank?

        @data ||= purchases.map do |purchase|
          [vendor.name, purchase.total_ppv, purchase.purchase_date.strftime("%-m/%-d/%Y"), purchase.id]
        end
      end
    end
  end
end
