module Reports
  module NetSuite
    class OrderExport
      include CsvExport

      FIELDS = %w(tranId status customerRef tranDate memo shipAttention shipAddressee shipAddr1 shipAddr2 shipCity
                  shipState shipZip lineId itemLine_itemRef itemLine_quantity itemLine_serialNumbers itemLine_salesPrice
                  itemLine_amount itemLine_description).freeze

      def each
        Order.includes(:user, :organization_unscoped, order_details: :item).order(:id).each do |order|
          # Note: If the sort of the included class (OrderDetail) were done in the
          # order() above, it would do a single query instead of 1 query for each
          # class loaded, so use sort_by on the small set of details rather than
          # doing a super large single query.
          order.order_details.sort_by(&:id).each_with_index do |detail, i|
            yield Row.new(order, detail, i)
          end
        end
      end

      class Row
        attr_reader :order, :order_detail, :index,
                    :ship_attention, :ship_addr1, :ship_addr2, :ship_city, :ship_state, :ship_zip
        delegate :status, to: :order

        def initialize(order, order_detail, index)
          @order = order
          @order_detail = order_detail
          @index = index
          extract_address
        end

        def tran_id
          "Order-#{order.id}"
        end

        def customer_ref
          order.organization_unscoped.name
        end

        def tran_date
          order.order_date.strftime("%m/%d/%Y")
        end

        def memo
          ["Order placed by #{order.user.name}", order.notes.presence].compact.join("\n")
        end

        def ship_addressee
          order.ship_to_name
        end

        def line_id
          index + 1
        end

        def item_line_item_ref
          "item-#{order_detail.item.id}"
        end

        def item_line_quantity
          order_detail.quantity
        end

        def item_line_serial_numbers
          order_detail.item.sku
        end

        def item_line_sales_price
          ActionController::Base.helpers.number_to_currency(order_detail.value, unit: "$", precision: 2)
        end

        def item_line_amount
          ActionController::Base.helpers.number_to_currency(order_detail.total_value, unit: "$", precision: 2)
        end

        def item_line_description
          order_detail.item.description
        end

        private

        def extract_address
          result = AddressParser.new.parse(order.ship_to_address)
          @ship_attention = result[:attention]
          @ship_addr1 = result[:address1]
          @ship_addr2 = result[:address2]
          @ship_city = result[:city]
          @ship_state = result[:state]
          @ship_zip = result[:zip]
        end
      end
    end
  end
end
