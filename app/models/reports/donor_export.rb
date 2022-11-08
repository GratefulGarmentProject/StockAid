module Reports
  class DonorExport
    include CsvExport

    FIELDS = %w[id name email cell_phone other_phone address date_created external_id external_type].freeze

    def initialize(current_user, _session)
      @current_user = current_user
      @donors = Donor.includes(:addresses).active.order(:name)
    end

    def each
      @donors.each do |donor|
        yield Row.new(donor)
      end
    end

    class Row
      attr_reader :donor, :cell_phone, :other_phone, :address, :date_created, :external_id

      delegate :id, :name, :email, :external_type, to: :donor

      def initialize(donor)
        @donor = donor
        @cell_phone = donor.primary_number
        @other_phone = donor.secondary_number
        @address = donor.primary_address
        @date_created = donor.created_at.strftime("%m/%d/%Y")
        @external_id = NetSuiteIntegration.external_id_or_status_text(donor)
      end
    end
  end
end
