module Reports
  class Graphs
    def order_count_by_day
      total = 0

      order_count = Order.group("date(created_at)").count
      order_count = Hash[order_count.sort_by { |k, _| k }]
      Hash[order_count.map do |k, v|
        total += v
        [k, total]
      end]
    end

    def order_count_by_month
      results = {}

      order_count = Order.all.group_by { |m| m.created_at.beginning_of_month }
      order_count.each { |k, v| results[k.to_date] = v.count }

      results
    end

    def items_sent_count_by_month
      results = {}

      order_details = OrderDetail.joins(:order).where(orders: { status: 6 })
                                 .group_by { |m| m.created_at.beginning_of_month }
      order_details.each { |datetime, od| results[datetime.strftime("%B %Y")] = od.map(&:quantity).sum }

      results
    end
  end
end
