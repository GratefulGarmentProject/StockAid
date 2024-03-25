module Reports
  module PricePointVariance
    attr_accessor :params, :start_date, :end_date

    def self.new(params, session)
      filter = Reports::Filter.new(session)

      if params[:vendor_id].present?
        Reports::PricePointVariance::SingleVendor.new(params, filter)
      else
        Reports::PricePointVariance::AllVendors.new(params, filter)
      end
    end

    def self.vendors
      Vendor.order(:name)
    end

    module Base
      def apply_filters(filter, scope)
        scope =
          if breakdown_by_status?
            scope
          else
            # Currently, if status_filter is breakdown_by_status, we fetch
            # everything, otherwise it is closed_only which will only report on
            # closed purchases
            scope.where(status: :closed)
          end

        filter.apply_date_filter(scope, :purchase_date)
      end

      def each
        data.each { |x| yield(*x) }
      end

      def breakdown_by_status?
        params[:status_filter] == "breakdown_by_status"
      end

      def include_purchase_date?
        false
      end

      def total_value
        @total_value ||= @data.map { |row| row[1] }.sum
      end

      def totals_breakdown
        [].tap do |result|
          if breakdown_by_status?
            purchases_by_status = purchases.group_by(&:status)

            Purchase::ALL_STATUSES.each do |status|
              next if purchases_by_status[status].blank?

              result << {
                status: status.humanize(capitalize: false),
                total: purchases_by_status[status].sum(&:total_ppv)
              }
            end
          end
        end
      end
    end

    class AllVendors
      include Reports::PricePointVariance::Base
      attr_reader :params, :purchases

      def initialize(params, filter)
        @params = params
        @purchases = apply_filters(filter, Purchase.all).includes(:vendor, :purchase_details).to_a
      end

      def description_label
        "Vendor"
      end

      def data
        @data ||=
          begin
            purchases_by_vendor = purchases.group_by(&:vendor)

            purchases_by_vendor.keys.sort.map do |vendor|
              total_ppv = purchases_by_vendor[vendor].map(&:total_ppv).inject(0, :+)
              [vendor.name, total_ppv, nil, nil, vendor.id]
            end
          end
      end
    end

    class SingleVendor
      include Reports::PricePointVariance::Base
      attr_reader :params, :vendor, :purchases

      def initialize(params, filter)
        @params = params
        @vendor = Vendor.find params[:vendor_id]
        @purchases = apply_filters(filter, @vendor.purchases).includes(:purchase_details).to_a
      end

      def description_label
        "Purchase"
      end

      def data
        return [] if purchases.blank?

        @data ||= purchases.map do |purchase|
          [purchase.id, purchase.total_ppv, purchase.purchase_date.strftime("%-m/%-d/%Y"), purchase.id, vendor.id]
        end
      end

      def include_purchase_date?
        true
      end
    end
  end
end
