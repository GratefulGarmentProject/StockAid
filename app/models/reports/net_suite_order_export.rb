require "csv"

module Reports
  class NetSuiteOrderExport
    FIELDS = %w(tranId customerRef tranDate memo shipAttention shipAddressee shipAddr1 shipAddr2 shipCity shipState
                shipZip itemLine_itemRef itemLine_quantity itemLine_serialNumbers itemLine_salesPrice itemLine_amount
                itemLine_description).freeze

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << FIELDS

        each do |row|
          csv << FIELDS.map { |field| row[field] }
        end
      end
    end

    def each
      Order.includes(:user, :organization_unscoped, order_details: :item).order(:id).each_with_index do |order, i|
        # Note: If the sort of the included class (OrderDetail) were done in the
        # order() above, it would do a single query instead of 1 query for each
        # class loaded, so use sort_by on the small set of details rather than
        # doing a super large single query.
        order.order_details.sort_by(&:id).each do |detail|
          yield Row.new(order, detail, i)
        end
      end
    end

    class Row
      attr_reader :order, :order_detail, :index

      def initialize(order, order_detail, index)
        @order = order
        @order_detail = order_detail
        @index = index
        extract_address
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def [](field)
        case field
        when "tranId"
          "Order-#{order.id}"
        when "customerRef"
          order.organization_unscoped.name
        when "tranDate"
          order.order_date.strftime("%m/%d/%Y")
        when "memo"
          memo
        when "shipAttention"
          @ship_attention
        when "shipAddressee"
          order.ship_to_name
        when "shipAddr1"
          @ship_address1
        when "shipAddr2"
          @ship_address2
        when "shipCity"
          @ship_city
        when "shipState"
          @ship_state
        when "shipZip"
          @ship_zip
        when "lineId"
          index + 1
        when "itemLine_itemRef"
          "item-#{order_detail.item.id}"
        when "itemLine_quantity"
          order_detail.quantity
        when "itemLine_serialNumbers"
          order_detail.item.sku
        when "itemLine_salesPrice"
          ActionController::Base.helpers.number_to_currency(order_detail.value, unit: "$", precision: 2)
        when "itemLine_amount"
          order_detail.total_value
        when "itemLine_description"
          order_detail.item.description
        end
      end

      def memo
        ["Order placed by #{order.user.name}", order.notes.presence].compact.join("\n")
      end

      private

      def extract_address
        result = AddressParser.new.parse(order.ship_to_address)
        @ship_attention = result[:attention]
        @ship_address1 = result[:address1]
        @ship_address2 = result[:address2]
        @ship_city = result[:city]
        @ship_state = result[:state]
        @ship_zip = result[:zip]
      end
    end
  end
end
