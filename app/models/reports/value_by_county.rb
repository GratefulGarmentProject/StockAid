# frozen_string_literal: true

module Reports
  module ValueByCounty
    NO_COUNTY = "No County".freeze

    def self.new(params, session)
      filter = Reports::Filter.new(session)

      if params[:all_orgs] == "true"
        Reports::ValueByCounty::AllOrganizations.new(filter)
      elsif params[:county].present?
        Reports::ValueByCounty::SingleCounty.new(filter, params)
      else
        Reports::ValueByCounty::AllCounties.new(filter)
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

      def initialize(filter, params)
        @filter = filter
        @county = params[:county]
        @organizations = find_organizations.order(:name).includes(approved_orders: :order_details)
      end

      def description_label
        "Organization"
      end

      private

      def data
        @data ||= organizations.map do |org|
          orders = @filter.apply_date_filter(org.approved_orders, :order_date).to_a
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
      def initialize(filter)
        @filter = filter
      end

      def reports
        @reports ||= Reports::ValueByCounty.counties.map do |county|
          SingleCounty.new(@filter, county: county)
        end
      end
    end

    class AllCounties
      include Reports::ValueByCounty::Base
      attr_reader :organizations

      def initialize(filter)
        @filter = filter
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
          orgs_orders = orgs.map { |org| @filter.apply_date_filter(org.approved_orders, :order_date).to_a }
          [county,
           orgs_orders.sum { |orders| orders.sum(&:item_count) },
           orgs_orders.sum { |orders| orders.sum(&:value) }]
        end
      end
    end
  end
end
