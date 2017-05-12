module Reports
  module Graphs
    def self.order_count_by_day
      total = 0
      results = {}

      order_count = Order.group("date(created_at)").count
      order_count = Hash[order_count.sort_by { |k, _| k }]
      order_count.each do |k, v|
        total += v
        results[k] = total
      end
      results
    end

    def self.order_count_by_month
      results = {}

      order_count = Order.all.group_by { |m| m.created_at.beginning_of_month }
      order_count.map { |k, v| results[k] = v.count }
      results
    end
  end
end
