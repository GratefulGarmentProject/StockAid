module Reports
  module NetSuite
    class DonationExport
      include CsvExport

      FIELDS = %w(donationDate donorName donorEmail addr1 addr2 city state zip
                  donorExternalId donorExternalType memo itemName value revenueStream).freeze

      def each
        Donation.includes(:user, :donor, donation_details: :item).order(:id).each do |donation|
          yield Row.new(donation)
        end
      end

      class Row
        attr_reader :donation, :donor, :addr1, :addr2, :city, :state, :zip

        delegate :external_id, to: :donor, prefix: true
        delegate :external_type, to: :donor, prefix: true
        delegate :name, to: :donor, prefix: true
        delegate :email, to: :donor, prefix: true

        def initialize(donation)
          @donation = donation
          @donor = donation.donor
          extract_address
        end

        def donation_date
          donation.donation_date.strftime("%m/%d/%Y")
        end

        def memo
          ["Donation received by #{donation.user.name}", donation.notes.presence].compact.join("\n")
        end

        def item_name
          "in-kind donation"
        end

        def value
          donation.value.to_s
        end

        def revenue_stream
          # Impliment with revenue streams
          nil
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
