module Reports
  module Graphs
    def self.order_count_by_day
      total = 0

      order_count = Order.group("date(created_at)").count
      order_count = Hash[order_count.sort_by { |k, _| k }]
      Hash[order_count.map do |k, v|
        total += v
        [k, total]
      end]
    end

    def self.order_count_by_month
      results = {}

      order_count = Order.all.group_by { |m| m.created_at.beginning_of_month }
      order_count.map { |k, v| results[k] = v.count }
      Hash[results.map { |k, v| [k.to_date, v] }]
    end
  end
end
