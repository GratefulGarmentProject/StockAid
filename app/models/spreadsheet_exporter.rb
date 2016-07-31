class SpreadsheetExporter
  def initialize
    @workbook = Spreadsheet::Workbook.new
  end

  def master_inventory
    sheet1 = SpreadsheetExporter::Sheet.new(@workbook, "All Items")
    sheet1 << %w(Category Description Quantity\ On\ hand SKU Value)
    fill_sheet_with_inventory(sheet1)
    @workbook
  end

  private

  def fill_sheet_with_inventory(sheet)
    Category.all.find_each do |category|
      sheet << [category.description]

      category.items.all.find_each do |item|
        sheet << ["", item.description.to_s, item.current_quantity.to_s, item.sku.to_s, item.value.to_s]
      end
    end
  end

  class Sheet
    def initialize(workbook, name)
      @sheet = workbook.create_worksheet
      @sheet.name = name
      @next_row = 0
    end

    def <<(row)
      @sheet.row(@next_row).concat(row)
      @next_row += 1
    end
  end
end
