module Reports
  module AnnualInventoryPpv
    def self.new()
      Reports::AnnualInventoryPpv::AllYears.new()
    end

    def self.years
      AnnualInventoryPpv.all.pluck(:year).uniq.sort
    end

    module Base
      def each
        data.each { |x| yield(*x) }
      end
    end

    class AllYears
      include Reports::AnnualInventoryPpv::Base
      attr_reader :annual_inventory_ppvs

      def initialize()
        @annual_inventory_ppvs = ::AnnualInventoryPpv.order(:year).to_a
      end

      def description_label
        "Vendor"
      end

      def data
        @data ||= annual_inventory_ppvs.map do |annual_inventory_ppv|
          [annual_inventory_ppv.year, annual_inventory_ppv.total_inventory_value,
           annual_inventory_ppv.annual_ppv,annual_inventory_ppv.real_inventory_value]
        end
      end
    end
  end
end
