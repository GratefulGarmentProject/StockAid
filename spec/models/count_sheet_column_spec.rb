require "rails_helper"

describe CountSheetColumn do
  describe "#count" do
    let(:column) do
      CountSheetColumn.new.tap do |column|
        column.counter_name = "Foo Bar"
        column.add_count("1", "5")
        column.add_count("2", "3")
      end
    end

    it "returns the count for a detail id" do
      expect(column.count(1)).to eq(5)
      expect(column.count(2)).to eq(3)
    end

    it "raises on missing detail id" do
      expect do
        column.count(3)
      end.to raise_error(ArgumentError)
    end
  end

  describe ".parse" do
    it "extracts columns from the params" do
      columns = CountSheetColumn.parse({
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          "1" => %w[1 2],
          "2" => %w[3 4]
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
      expect(columns.first.counter_name).to eq("Foo Bar")
      expect(columns.first.counts).to eq(1 => 1, 2 => 3)

      expect(columns.last.counter_name).to eq("Baz Qux")
      expect(columns.last.counts).to eq(1 => 2, 2 => 4)
    end

    it "doesn't include empty end columns" do
      columns = CountSheetColumn.parse({
        counter_names: ["Foo Bar", "Baz Qux", ""],
        counts: {
          "1" => ["1", "2", ""],
          "2" => ["3", "4", ""]
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
      expect(columns.first.counter_name).to eq("Foo Bar")
      expect(columns.first.counts).to eq(1 => 1, 2 => 3)

      expect(columns.last.counter_name).to eq("Baz Qux")
      expect(columns.last.counts).to eq(1 => 2, 2 => 4)
    end

    it "doesn't include empty middle columns" do
      columns = CountSheetColumn.parse({
        counter_names: ["Foo Bar", "", "Baz Qux"],
        counts: {
          "1" => ["1", "", "2"],
          "2" => ["3", "", "4"]
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
      expect(columns.first.counter_name).to eq("Foo Bar")
      expect(columns.first.counts).to eq(1 => 1, 2 => 3)

      expect(columns.last.counter_name).to eq("Baz Qux")
      expect(columns.last.counts).to eq(1 => 2, 2 => 4)
    end

    it "doesn't include empty beginning columns" do
      columns = CountSheetColumn.parse({
        counter_names: ["", "Foo Bar", "Baz Qux"],
        counts: {
          "1" => ["", "1", "2"],
          "2" => ["", "3", "4"]
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
      expect(columns.first.counter_name).to eq("Foo Bar")
      expect(columns.first.counts).to eq(1 => 1, 2 => 3)

      expect(columns.last.counter_name).to eq("Baz Qux")
      expect(columns.last.counts).to eq(1 => 2, 2 => 4)
    end

    it "raises if a column has partial data" do
      expect do
        CountSheetColumn.parse({
          counter_names: ["Partial Data", "Foo Bar", "Baz Qux"],
          counts: {
            "1" => %w[1 1 2],
            "2" => ["", "3", "4"]
          }
        }.with_indifferent_access)
      end.to raise_error(ArgumentError)
    end

    it "raises if a column has no counter name" do
      expect do
        CountSheetColumn.parse({
          counter_names: ["", "Foo Bar", "Baz Qux"],
          counts: {
            "1" => %w[1 1 2],
            "2" => %w[2 3 4]
          }
        }.with_indifferent_access)
      end.to raise_error(ArgumentError)
    end

    it "supports parsing new rows with no existing rows" do
      columns = CountSheetColumn.parse({
        counter_names: ["Foo Bar", "Baz Qux"],
        new_count_sheet_items: {
          "5" => {
            item_id: "142",
            counts: %w[3 4]
          },
          "42" => {
            item_id: "1042",
            counts: %w[10 12]
          }
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
      expect(columns.first.counter_name).to eq("Foo Bar")
      expect(columns.first.counts).to eq({})
      expect(columns.first.new_counts).to eq(142 => 3, 1042 => 10)

      expect(columns.last.counter_name).to eq("Baz Qux")
      expect(columns.last.new_counts).to eq(142 => 4, 1042 => 12)
    end

    it "supports parsing new rows with existing rows" do
      columns = CountSheetColumn.parse({
        counter_names: ["Foo Bar", "Baz Qux"],
        counts: {
          "1" => %w[1 2],
          "2" => %w[3 4]
        },
        new_count_sheet_items: {
          "5" => {
            item_id: "142",
            counts: %w[3 4]
          },
          "42" => {
            item_id: "1042",
            counts: %w[10 12]
          }
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
      expect(columns.first.counter_name).to eq("Foo Bar")
      expect(columns.first.counts).to eq(1 => 1, 2 => 3)
      expect(columns.first.new_counts).to eq(142 => 3, 1042 => 10)

      expect(columns.last.counter_name).to eq("Baz Qux")
      expect(columns.last.counts).to eq(1 => 2, 2 => 4)
      expect(columns.last.new_counts).to eq(142 => 4, 1042 => 12)
    end

    it "raises if new count sheet items are missing" do
      expect do
        CountSheetColumn.parse({
          counter_names: ["Foo Bar", "Baz Qux"],
          counts: {
            "1" => %w[1 2],
            "2" => %w[3 4]
          },
          new_count_sheet_items: {
            "5" => {
              item_id: "142",
              counts: ["3", ""]
            },
            "42" => {
              item_id: "1042",
              counts: %w[10 12]
            }
          }
        }.with_indifferent_access)
      end.to raise_error(ArgumentError)
    end

    it "raises if all new count sheet items are missing for an otherwise existing column" do
      expect do
        CountSheetColumn.parse({
          counter_names: ["Foo Bar", "Baz Qux"],
          counts: {
            "1" => %w[1 2],
            "2" => %w[3 4]
          },
          new_count_sheet_items: {
            "5" => {
              item_id: "142",
              counts: ["3", ""]
            },
            "42" => {
              item_id: "1042",
              counts: ["10", ""]
            }
          }
        }.with_indifferent_access)
      end.to raise_error(ArgumentError)
    end

    it "raises if all new count sheet items are present but existing items are not" do
      expect do
        CountSheetColumn.parse({
          counter_names: ["Foo Bar", "Baz Qux"],
          counts: {
            "1" => ["1", ""],
            "2" => ["3", ""]
          },
          new_count_sheet_items: {
            "5" => {
              item_id: "142",
              counts: %w[3 4]
            },
            "42" => {
              item_id: "1042",
              counts: %w[10 12]
            }
          }
        }.with_indifferent_access)
      end.to raise_error(ArgumentError)
    end

    it "doesn't include empty column of just new counts" do
      columns = CountSheetColumn.parse({
        counter_names: ["Foo Bar", "Baz Qux", ""],
        new_count_sheet_items: {
          "5" => {
            item_id: "142",
            counts: ["3", "4", ""]
          },
          "42" => {
            item_id: "1042",
            counts: ["10", "12", ""]
          }
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
    end

    it "doesn't include empty column of new and old counts" do
      columns = CountSheetColumn.parse({
        counter_names: ["Foo Bar", "Baz Qux", ""],
        counts: {
          "1" => ["1", "2", ""],
          "2" => ["3", "4", ""]
        },
        new_count_sheet_items: {
          "5" => {
            item_id: "142",
            counts: ["3", "4", ""]
          },
          "42" => {
            item_id: "1042",
            counts: ["10", "12", ""]
          }
        }
      }.with_indifferent_access)

      expect(columns.size).to eq(2)
    end
  end
end
