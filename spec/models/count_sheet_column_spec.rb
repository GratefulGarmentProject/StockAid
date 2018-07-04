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
          "1" => %w(1 2),
          "2" => %w(3 4)
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
            "1" => %w(1 1 2),
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
            "1" => %w(1 1 2),
            "2" => %w(2 3 4)
          }
        }.with_indifferent_access)
      end.to raise_error(ArgumentError)
    end
  end
end
