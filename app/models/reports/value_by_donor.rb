module Reports
  module ValueByDonor
    def self.new(params, session)
      filter = Reports::Filter.new(session)

      if params[:donor].present?
        Reports::ValueByDonor::SingleDonor.new(params, filter)
      else
        Reports::ValueByDonor::AllDonors.new(filter)
      end
    end

    def self.donors
      Donor.order(:name).all
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

    class SingleDonor
      include Reports::ValueByDonor::Base
      attr_reader :donor, :donations

      def initialize(params, filter)
        @donor = Donor.find params[:donor]
        @donations = filter.apply_date_filter(@donor.donations.active, :donation_date)
                           .includes(donation_details: :item)
                           .to_a.map(&:donation_details).flatten.group_by(&:item)
      end

      def description_label
        "Item"
      end

      def data
        @data ||= donations.keys.sort_by { |item| item_description(item) }.map do |item|
          item_donations = donations[item]
          [item_description(item),
           item_donations.sum(&:quantity),
           item_donations.sum(&:total_value)]
        end
      end

      def item_description(item)
        item&.description || "Unknown Item"
      end
    end

    class AllDonors
      include Reports::ValueByDonor::Base
      attr_reader :donations

      def initialize(filter)
        @donations = filter.apply_date_filter(Donation.active.all, :donation_date)
                           .includes(:donor, donation_details: :item)
                           .to_a.group_by(&:donor)
      end

      def description_label
        "Donor"
      end

      def data
        @data ||= donations.keys.sort.map do |donor|
          donor_donations = donations[donor]
          [donor.name,
           donor_donations.sum(&:item_count),
           donor_donations.sum(&:value),
           donor.id]
        end
      end
    end
  end
end
