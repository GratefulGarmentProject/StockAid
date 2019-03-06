module Reports
  module NetSuite
    class DonationExport
      include CsvExport

      FIELDS = %w(donationDate donorName donorEmail addr1 addr2 city state zip externalId externalType memo itemName value).freeze

      def each
        Donation.includes(:user, :donor, donation_details: :item).order(:id).each do |donation|
          yield Row.new(donation)
          # Note: If the sort of the included class (DonationDetail) were done
          # in the order() above, it would do a single query instead of 1 query
          # for each class loaded, so use sort_by on the small set of details
          # rather than doing a super large single query.
          # donation.donation_details.sort_by(&:id).each_with_index do |detail, i|
          # end
        end
      end

      class Row
        attr_reader :donation, :donor, :addr1, :addr2, :city, :state, :zip

        def initialize(donation)
          @donation = donation
          @donor = donation.donor
          extract_address
        end

        def external_id
          donor.external_id
        end

        def external_type
          donor.external_type
        end

        def donation_date
          donation.donation_date.strftime("%m/%d/%Y")
        end

        def memo
          ["Donation received by #{donation.user.name}", donation.notes.presence].compact.join("\n")
        end

        def donor_name
          donor.name
        end

        def donor_email
          donor.email
        end

        def item_name
          'in-kind donation'
        end

        def value
          donation.value.to_s
        end

        private

        def extract_address
          result = AddressParser.new.parse(donation.donor.primary_address)
          @attention = result[:attention]
          @addr1 = result[:address1]
          @addr2 = result[:address2]
          @city = result[:city]
          @state = result[:state]
          @zip = result[:zip]
        end
      end
    end
  end
end
