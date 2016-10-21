module Reports
  module ValueByCounty
    NO_COUNTY = "No County".freeze

    def self.new(params)
      if params[:all_orgs] == "true"
        Reports::ValueByCounty::AllOrganizations.new
      elsif params[:county].present?
        Reports::ValueByCounty::SingleCounty.new(params)
      else
        Reports::ValueByCounty::AllCounties.new
      end
    end

    def self.counties
      Organization.counties.map { |x| x.presence || NO_COUNTY }.uniq.sort
    end

    module Base
      def each
        data.each { |x| yield(*x) }
      end

      def total_item_count
        data.map { |x| x[1] }.sum
      end

      def total_value
        data.map { |x| x[2] }.sum
      end
    end

    class SingleCounty
      include Reports::ValueByCounty::Base
      attr_reader :county, :organizations

      def initialize(params)
        @county = params[:county]
        @organizations = find_organizations.order(:name).includes(approved_orders: :order_details)
      end

      def description_label
        "Organization"
      end

      private

      def data
        @data ||= organizations.map do |org|
          orders = org.approved_orders.to_a
          [org.name, orders.sum(&:item_count), orders.sum(&:value)]
        end
      end

      def find_organizations
        if county == NO_COUNTY
          Organization.where("county IS NULL OR county = ''")
        else
          Organization.where(county: county)
        end
      end
    end

    class AllOrganizations
      def reports
        @reports ||= Reports::ValueByCounty.counties.map do |county|
          SingleCounty.new(county: county)
        end
      end
    end

    class AllCounties
      include Reports::ValueByCounty::Base
      attr_reader :organizations

      def initialize
        @organizations = Organization.includes(approved_orders: :order_details).all
                                     .group_by { |org| org.county.presence || NO_COUNTY }
      end

      def description_label
        "County"
      end

      private

      def data
        @data ||= organizations.keys.sort.map do |county|
          orgs = organizations[county]
          orgs_orders = orgs.map { |org| org.approved_orders.to_a }
          [county,
           orgs_orders.sum { |orders| orders.sum(&:item_count) },
           orgs_orders.sum { |orders| orders.sum(&:value) }]
        end
      end
    end
  end
end
