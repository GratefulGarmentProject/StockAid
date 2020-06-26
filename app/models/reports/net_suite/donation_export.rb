module Reports
  module NetSuite
    class DonationExport
      include CsvExport

      FIELDS = %w[donationId donationDate donorName donorEmail addr_1 addr_2 city state zip
                  donorExternalId donorExternalType memo itemName value revenueStream].freeze

      def initialize(session)
        @session = session
        filter = Reports::Filter.new(@session)
        records = Donation.active.includes(:user, :donor, donation_details: :item).order(:id)
        @donations = filter.apply_date_filter(records, :donation_date)
      end

      def records_present?
        @donations.exists?
      end

      def each
        @donations.each do |donation|
          yield Row.new(donation)
        end
      end

      class Row
        attr_reader :donation, :donor, :addr_1, :addr_2, :city, :state, :zip

        delegate :name, :email, :external_id, :external_type, to: :donor, prefix: true
        delegate :id, to: :donation, prefix: true

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
          @addr_1 = result[:address1]
          @addr_2 = result[:address2]
          @city = result[:city]
          @state = result[:state]
          @zip = result[:zip]
        end
      end
    end
  end
end
