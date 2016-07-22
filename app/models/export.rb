require "spreadsheet"
require "stringio"
require "tempfile"

class Export
  attr_reader :error_message

  def initialize
    return unless block_given?

    begin
      yield(self)
    ensure
      close
    end
  end

  def stream_response(response)
    @response = response

    create_spreadsheet
    tempfile.open

    while str = tempfile.read(1024) # rubocop:disable Lint/AssignmentInCondition
      response.stream.write(str)
    end
  ensure
    tempfile.close
  end

  def close
    @response.stream.close if @response
    @tempfile.close! if @tempfile
  end

  def filename
    @filename ||= "master_inventory_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xls"
  end

  def tempfile
    @tempfile ||= Tempfile.new(filename)
  end

  def create_spreadsheet
    return if @created
    begin
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet
      sheet1.name = "All Items"
      sheet1.row(0).concat %w{ Category Description Quantity\ On\ hand SKU Value }
      row_num = 1
      # Add Headers
      Category.all.each do |category|
        category.items.all.each_with_index do |item, index|
          row = sheet1.row(row_num)
          if index.zero?
            row.push category.description
            row_num += 1
            next
          else
            row.concat ["", item.description.to_s, item.current_quantity.to_s, item.sku.to_s, item.value.to_s]
            row_num += 1
          end
        end
      end

      book.write tempfile
    rescue => e
      Rails.logger.error "Spreadsheet wasn't able to be created and written to file
        *** Error Output ***
#{e}
        *** End Error Output ***"
      @error_message = "Error creating spreadsheet!"
    ensure
      @created = true
    end
  end
end
