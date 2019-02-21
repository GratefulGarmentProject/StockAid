module Reports
  module NetSuite
    class DonorExport
      include CsvExport

      FIELDS = %w(id name email createdDate attention addr1 addr2 city state zip externalId externalType).freeze

      def each
        Donor.order(:id).each do |donor|
          yield Row.new(donor)
        end
      end

      class Row
        attr_reader :donor, :attention, :addr1, :addr2, :city, :state, :zip
        delegate :name, :email, :external_id, :external_type, to: :donor

        def initialize(donor)
          @donor = donor
          extract_address
        end

        def id
          "Donor-#{donor.id}"
        end

        def created_date
          donor.created_at.strftime("%m/%d/%Y")
        end

        private

        def extract_address
          result = AddressParser.new.parse(donor.primary_address)
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
