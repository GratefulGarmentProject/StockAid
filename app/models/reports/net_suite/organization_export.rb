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
          @address1[:attention]
        end

        def address1_addr1
          @address1[:address1]
        end

        def address1_addr2
          @address1[:address2]
        end

        def address1_city
          @address1[:city]
        end

        def address1_state
          @address1[:state]
        end

        def address1_zip
          @address1[:zip]
        end

        def address2_attention
          @address2[:attention]
        end

        def address2_addr1
          @address2[:address1]
        end

        def address2_addr2
          @address2[:address2]
        end

        def address2_city
          @address2[:city]
        end

        def address2_state
          @address2[:state]
        end

        def address2_zip
          @address2[:zip]
        end

        def address3_attention
          @address3[:attention]
        end

        def address3_addr1
          @address3[:address1]
        end

        def address3_addr2
          @address3[:address2]
        end

        def address3_city
          @address3[:city]
        end

        def address3_state
          @address3[:state]
        end

        def address3_zip
          @address3[:zip]
        end

        private

        def extract_addresses
          addresses = organization.addresses.sort_by(&:id).map(&:to_s)
          parser = AddressParser.new
          @address1 = parser.parse(addresses[0])
          @address2 = parser.parse(addresses[1])
          @address3 = parser.parse(addresses[2])
        end
      end
    end
  end
end
