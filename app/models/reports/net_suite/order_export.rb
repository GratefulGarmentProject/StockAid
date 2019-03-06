module Reports
  module NetSuite
    class OrderExport
      include CsvExport

      FIELDS = %w(orderDate organizationName organizationExternalId
                  organizationExternalType memo value revenueStream).freeze

      def each
        Order.includes(:user, :organization_unscoped, order_details: :item).order(:id).each do |order|
          yield Row.new(order)
        end
      end

      class Row
        attr_reader :order, :organization

        delegate :status, to: :order
        delegate :name, to: :organization, prefix: true
        delegate :external_id, to: :organization, prefix: true
        delegate :external_type, to: :organization, prefix: true

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
