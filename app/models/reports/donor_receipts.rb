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
      donations_by_donor = @filter.apply_date_filter(Donation.closed, :donation_date)
                                  .where(donor_id: @params[:donor_ids])
                                  .includes([{ donor: :addresses }, { donation_details: :item }])
                                  .to_a.group_by(&:donor)

      result = donations_by_donor.map do |donor, donations|
        Reports::DonorReceipts::Receipt.new(donor, donations)
      end

      result.sort_by { |receipt| receipt.donor.name }
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
        donor.first_address
      end

      def donor_address_line_1
        if donor_address.all_parts_present?
          donor_address.street_address
        else
          donor_address
        end
      end

      def donor_address_line_2
        "#{donor_address.city}, #{donor_address.state} #{donor_address.zip}" if donor_address.all_parts_present?
      end

      def donor_email
        donor.email
      end

      def total_items
        donation_items.map(&:quantity).sum
      end

      def donation_items
        @donation_items ||=
          begin
            item_map = {}

            @donations.each do |d|
              d.donation_details.each do |detail|
                item_map[detail.item_id] ||= DonorReceipts::Item.new(detail.item.description)
                item_map[detail.item_id].add(detail.quantity)
              end
            end

            item_map.values.sort_by(&:description)
          end
      end
    end

    class Item
      attr_reader :description, :quantity

      def initialize(description, quantity = 0)
        @description = description
        @quantity = quantity
      end

      def add(amount)
        @quantity += amount
      end
    end
  end
end
