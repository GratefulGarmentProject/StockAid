module Reports
  module NetSuite
    class OrderExport
      include CsvExport

      FIELDS = %w(orderId orderDate organizationName organizationExternalId
                  organizationExternalType memo value revenueStream).freeze

      def initialize(session)
        @session = session
        filter = Reports::Filter.new(@session)
        records = Order.includes(:user, :organization_unscoped, order_details: :item).closed.order(:id)
        @orders = filter.apply_date_filter(records, :order_date)
      end

      def records_present?
        @orders.exists?
      end

      def each
        @orders.each do |order|
          yield Row.new(order)
        end
      end

      class Row
        attr_reader :order, :organization

        delegate :id, to: :order, prefix: true
        delegate :name, :external_id, :external_type, to: :organization, prefix: true

        def initialize(order)
          @order = order
          @organization = order.organization_unscoped
        end

        def order_date
          order.order_date.strftime("%m/%d/%Y")
        end

        def memo
          ["Order placed by #{order.user.name}", order.notes.presence].compact.join("\n")
        end

        def value
          order.value.to_s
        end

        def revenue_stream
          # Impliment with revenue streams
          nil
        end
      end
    end
  end
end
