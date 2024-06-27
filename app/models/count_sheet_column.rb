class CountSheetColumn
  attr_accessor :counter_name, :counts, :new_counts

  def initialize
    @counts = {}
    @new_counts = {}
  end

  def self.parse(params)
    CountSheetColumn::Parser.new(params).parse
  end

  def add_count(id, count)
    count = count.to_i if count.present?
    counts[id.to_i] = count
  end

  def add_new_count(id, count)
    count = count.to_i if count.present?
    new_counts[id.to_i] = count
  end

  def empty?
    counter_name.blank? && counts.values.all?(&:blank?) && new_counts.values.all?(&:blank?)
  end

  def complete?
    counter_name.present? && counts.values.all?(&:present?) && new_counts.values.all?(&:present?)
  end

  def valid?
    empty? || complete?
  end

  def count(id)
    count = counts[id]
    raise ArgumentError, "Missing count for #{id}" if count.blank?
    count
  end

  def new_count(id)
    count = new_counts[id]
    raise ArgumentError, "Missing count for new id #{id}" if count.blank?
    count
  end

  class Parser
    attr_reader :params, :columns

    def initialize(params)
      @params = params
      @columns = []
    end

    def parse
      parse_existing_counts
      parse_new_counts
      validate_columns
      ignore_empty_columns
      columns
    end

    private

    def parse_existing_counts
      params[:counter_names].each_with_index do |name, i|
        column = CountSheetColumn.new
        column.counter_name = name

        (params[:counts] || {}).each do |id, counts|
          column.add_count(id, counts[i])
        end

        columns << column
      end
    end

    def parse_new_counts
      (params[:new_count_sheet_items] || {}).each_value do |new_item|
        columns.each_with_index do |column, i|
          column.add_new_count(new_item[:item_id], new_item[:counts][i])
        end
      end
    end

    def validate_columns
      columns.each do |column|
        raise ArgumentError, "Invalid count sheet column" unless column.valid?
      end
    end

    def ignore_empty_columns
      columns.reject!(&:empty?)
    end
  end
end
