class CountSheetColumn
  attr_accessor :counter_name, :counts

  def initialize
    @counts = {}
  end

  def self.parse(params)
    columns = []

    params[:counter_names].each_with_index do |name, i|
      column = CountSheetColumn.new
      column.counter_name = name

      params[:counts].each do |id, counts|
        column.add_count(id, counts[i])
      end

      raise ArgumentError, "Invalid count sheet column" unless column.valid?
      columns << column unless column.empty?
    end

    columns
  end

  def add_count(id, count)
    count = count.to_i if count.present?
    counts[id.to_i] = count
  end

  def empty?
    counter_name.blank? && counts.values.all?(&:blank?)
  end

  def complete?
    counter_name.present? && counts.values.all?(&:present?)
  end

  def valid?
    empty? || complete?
  end

  def count(id)
    count = counts[id]
    raise ArgumentError, "Missing count for #{id}" if count.blank?
    count
  end
end
