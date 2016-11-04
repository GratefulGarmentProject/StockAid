module Reports
  module ValueByDonor
    NO_DONOR = "Unknown Donor".freeze

    def self.new(params)
      if params[:donor].present?
        Reports::ValueByDonor::SingleDonor.new(params)
      else
        Reports::ValueByDonor::AllDonors.new
      end
    end

    def self.donors
      Item.paper_trail_version_class.where(edit_reason: "donation").uniq.pluck(:edit_source)
          .map { |x| x.presence || NO_DONOR }.sort
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

      def initialize(params)
        @donor = params[:donor]
        @donations = Reports::ValueByDonor::Donation.for_donor(donor).group_by(&:item)
      end

      def description_label
        "Item"
      end

      def data
        @data ||= donations.keys.sort_by { |item| item_descrtipion(item) }.map do |item|
          item_donations = donations[item]
          [item_descrtipion(item),
           item_donations.sum(&:amount),
           item_donations.sum(&:value)]
        end
      end

      def item_descrtipion(item)
        item.try(:description).presence || "Unknown Item"
      end
    end

    class AllDonors
      include Reports::ValueByDonor::Base
      attr_reader :donations

      def initialize
        @donations = Reports::ValueByDonor::Donation.all.group_by(&:donor)
      end

      def description_label
        "Donor"
      end

      def data
        @data ||= donations.keys.sort.map do |donor|
          donor_donations = donations[donor]
          [donor,
           donor_donations.sum(&:amount),
           donor_donations.sum(&:value)]
        end
      end
    end

    class Donation
      def self.all
        for_scope Item.paper_trail_version_class
      end

      def self.for_donor(donor)
        if donor == NO_DONOR
          for_scope Item.paper_trail_version_class.where("edit_source IS NULL OR edit_source = ''")
        else
          for_scope Item.paper_trail_version_class.where(edit_source: donor)
        end
      end

      def self.for_scope(scope)
        scope.includes(:item).where(edit_reason: "donation").all.map { |version| new(version) }
      end

      def initialize(version)
        @version = version
      end

      def item
        @version.item
      end

      def donor
        @version.edit_source.presence || NO_DONOR
      end

      def amount
        @amount ||=
          case @version.edit_method
          when "add"
            @version.edit_amount
          when "subtract"
            -@version.edit_amount
          when "new_total"
            @version.edit_amount
          else
            raise "Invalid donation method: #{@version.edit_method}"
          end
      end

      def value
        return 0 unless item
        item.value * amount
      end
    end
  end
end
