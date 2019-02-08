module Reports
  module NetSuite
    class DonationExport
      include CsvExport

      FIELDS = %w(tranId tranDate memo attention addressee addr1 addr2 city state zip lineId itemLine_itemRef
                  itemLine_quantity itemLine_serialNumbers itemLine_salesPrice itemLine_amount
                  itemLine_description).freeze

      def each
        Donation.includes(:user, :donor, donation_details: :item).order(:id).each do |donation|
          # Note: If the sort of the included class (DonationDetail) were done
          # in the order() above, it would do a single query instead of 1 query
          # for each class loaded, so use sort_by on the small set of details
          # rather than doing a super large single query.
          donation.donation_details.sort_by(&:id).each_with_index do |detail, i|
            yield Row.new(donation, detail, i)
          end
        end
      end

      class Row
        attr_reader :donation, :donation_detail, :index,
                    :attention, :addr1, :addr2, :city, :state, :zip

        def initialize(donation, donation_detail, index)
          @donation = donation
          @donation_detail = donation_detail
          @index = index
          extract_address
        end

        def tran_id
          "Donation-#{donation.id}"
        end

        def tran_date
          donation.donation_date.strftime("%m/%d/%Y")
        end

        def memo
          ["Donation received by #{donation.user.name}", donation.notes.presence].compact.join("\n")
        end

        def line_id
          index + 1
        end

        def item_line_item_ref
          "item-#{donation_detail.item.id}"
        end

        def item_line_quantity
          donation_detail.quantity
        end

        def item_line_serial_numbers
          donation_detail.item.sku
        end

        def item_line_sales_price
          ActionController::Base.helpers.number_to_currency(donation_detail.value, unit: "$", precision: 2)
        end

        def item_line_amount
          ActionController::Base.helpers.number_to_currency(donation_detail.total_value, unit: "$", precision: 2)
        end

        def item_line_description
          donation_detail.item.description
        end

        def addressee
          donation.donor.name
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
