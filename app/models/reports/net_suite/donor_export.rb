require "csv"

module Reports
  module NetSuite
    class DonorExport
      FIELDS = %w(id name email createdDate attention addr1 addr2 city state zip).freeze

      FIELDS_TO_METHOD_NAMES = Hash[FIELDS.map { |f| [f, f.underscore] }].freeze

      def to_csv(output = "")
        output << CSV.generate_line(FIELDS)

        each do |row|
          output << CSV.generate_line(FIELDS.map { |field| row.send(FIELDS_TO_METHOD_NAMES[field]) })
        end

        output
      end

      def each
        Donor.order(:id).each do |donor|
          yield Row.new(donor)
        end
      end

      class Row
        attr_reader :donor, :attention, :addr1, :addr2, :city, :state, :zip
        delegate :name, :email, to: :donor

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
          result = AddressParser.new.parse(donor.address)
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
