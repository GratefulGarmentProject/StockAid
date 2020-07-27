class SpreadsheetExporter
  def initialize
    @workbook = Spreadsheet::Workbook.new
  end

  def self.master_inventory
    SpreadsheetExporter::MasterInventory.new
  end

  def write(target)
    @workbook.write(target)
  end

  private

  def create_sheet(name)
    SpreadsheetExporter::Sheet.new(@workbook, name)
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

  class MasterInventory < SpreadsheetExporter
    def initialize
      super
      sheet_1 = create_sheet("All Items")
      sheet_1 << %w[Category Id Description Quantity\ On\ hand SKU Value]
      fill_sheet_with_inventory(sheet_1)
    end

    private

    def fill_sheet_with_inventory(sheet)
      Category.all.find_each do |category|
        sheet << [category.description]

        category.items.all.find_each do |item|
          sheet << ["", "Item-#{item.id}", item.description.to_s,
                    item.current_quantity.to_s, item.sku.to_s, item.value.to_s]
        end
      end
    end
  end
end
