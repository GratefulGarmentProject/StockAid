module Reports
  module NetSuite
    class OrganizationExport
      include CsvExport

      FIELDS = %w(id name county phoneNumber email createdDate
                  address1_attention address1_addr1 address1_addr2 address1_city address1_state address1_zip
                  address2_attention address2_addr1 address2_addr2 address2_city address2_state address2_zip
                  address3_attention address3_addr1 address3_addr2 address3_city address3_state address3_zip
                  externalId externalType).freeze

      def initialize(session)
        @session = session
        filter = Reports::Filter.new(@session)
        records = Organization.includes(:addresses).order(:id)
        @organizations = filter.apply_date_filter(records, :created_at)
      end

      def records_present?
        @organizations.exists?
      end

      def each
        @organizations.each do |organization|
          yield Row.new(organization)
        end
      end

      class Row
        attr_reader :organization
        delegate :name, :county, :phone_number, :email, :external_id, :external_type, to: :organization

        def initialize(organization)
          @organization = organization
          extract_addresses
        end

        def id
          "Organization-#{organization.id}"
        end

        def created_date
          organization.created_at.strftime("%m/%d/%Y")
        end

        def address1_attention
          @address_1[:attention]
        end

        def address1_addr1
          @address_1[:address1]
        end

        def address1_addr2
          @address_1[:address2]
        end

        def address1_city
          @address_1[:city]
        end

        def address1_state
          @address_1[:state]
        end

        def address1_zip
          @address_1[:zip]
        end

        def address2_attention
          @address_2[:attention]
        end

        def address2_addr1
          @address_2[:address1]
        end

        def address2_addr2
          @address_2[:address2]
        end

        def address2_city
          @address_2[:city]
        end

        def address2_state
          @address_2[:state]
        end

        def address2_zip
          @address_2[:zip]
        end

        def address3_attention
          @address_3[:attention]
        end

        def address3_addr1
          @address_3[:address1]
        end

        def address3_addr2
          @address_3[:address2]
        end

        def address3_city
          @address_3[:city]
        end

        def address3_state
          @address_3[:state]
        end

        def address3_zip
          @address_3[:zip]
        end

        private

        def extract_addresses
          addresses = organization.addresses.sort_by(&:id).map(&:to_s)
          parser = AddressParser.new
          @address_1 = parser.parse(addresses[0])
          @address_2 = parser.parse(addresses[1])
          @address_3 = parser.parse(addresses[2])
        end
      end
    end
  end
end
