class SpreadsheetExporter
  def initialize
    @workbook = Spreadsheet::Workbook.new
  end

  def master_inventory
    sheet1 = book.create_worksheet
    sheet1.name = "All Items"
    add_top_headers(sheet1, %w(Category Description Quantity\ On\ hand SKU Value))
    fill_sheet_with_inventory(sheet1)
    @workbook
  end

  private

  def add_top_headers(sheet, headers)
    sheet.row(0).concat headers
  end

  def fill_sheet_with_inventory(sheet) # rubocop:disable Metrics/AbcSize
    row_num = 1
    Category.all.find_each do |category|
      category.items.all.each_with_index do |item, index|
        row = sheet.row(row_num)
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
  end
end
