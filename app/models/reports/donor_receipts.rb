module Reports
  class DonorReceipts
    def initialize(params, session)
      @params = params
      @filter = Reports::Filter.new(session)
    end

    def donors
      donor_ids = @filter.apply_date_filter(Donation.closed, :donation_date).distinct.pluck(:donor_id)
      Donor.where(id: donor_ids).order(:name).to_a
    end

    def receipts
      donations = @filter.apply_date_filter(Donation.closed, :donation_date)
        .where(donor_id: @params[:donor_ids])
        .includes(donor: :addresses).to_a
      donations.group_by(&:donor).map do |donor, donations|
        Reports::DonorReceipts::Receipt.new(donor, donations)
      end.sort_by { |receipt| receipt.donor.name }
    end

    class Receipt
      attr_reader :donor, :donations

      def initialize(donor, donations)
        @donor = donor
        @donations = donations
      end

      def date
        Time.zone.now
      end

      def donor_full_name
        donor.name
      end

      def donor_first_name
        if donor.external_type == "Individual"
          donor.name.split(/\s+/).first
        else
          donor.name
        end
      end

      def donor_address
        donor.primary_address
      end

      def donor_email
        donor.email
      end

      def donations_list
        "TODO: donations_list"
      end
    end
  end
end
