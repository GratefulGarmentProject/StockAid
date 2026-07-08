require "rails_helper"

describe AddressParser do
  subject(:parser) { AddressParser.new }

  describe "#parse" do
    it "returns empty hash for nil" do
      expect(parser.parse(nil)).to eq({})
    end

    it "returns empty hash for HISTORICAL" do
      expect(parser.parse("HISTORICAL")).to eq({})
    end

    it "returns empty hash for 'confidential'" do
      expect(parser.parse("confidential")).to eq({})
    end

    it "returns empty hash for empty string" do
      expect(parser.parse("")).to eq({})
    end

    it "parses address1, address2, city, state, zip (comma-separated, 5 parts)" do
      result = parser.parse("100 Main St, Suite 200, San Jose, CA 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:address2]).to eq("Suite 200")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses address1, address2, city, state without zip" do
      result = parser.parse("100 Main St, Suite 200, San Jose, CA")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:address2]).to eq("Suite 200")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to be_nil
    end

    it "parses address1, city, state, zip without address2" do
      result = parser.parse("100 Main St, San Jose, CA 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses address1, city, state, zip with comma before zip" do
      result = parser.parse("100 Main St, San Jose, CA, 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses address1, city state zip (no comma between city/state)" do
      result = parser.parse("100 Main St, San Jose CA 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses Building format (address1, Building X city, state zip)" do
      result = parser.parse("100 Main St, Building A San Jose, CA 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:address2]).to eq("Building A")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses Oakland special case" do
      result = parser.parse("100 Main St Oakland, CA 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:city]).to eq("Oakland")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses Modesto special case" do
      result = parser.parse("100 Main St Modesto, CA 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:city]).to eq("Modesto")
    end

    it "parses Bascom Avenue special case (no commas in address)" do
      result = parser.parse("1234 Bascom Avenue Suite 100")
      expect(result[:address1]).to eq("1234 Bascom Avenue Suite 100")
    end

    it "parses C/O address format" do
      result = parser.parse("John C/O The Company, 100 Main St, San Jose, 95101")
      expect(result[:attention]).to eq("John C/O The Company")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:city]).to eq("San Jose")
      expect(result[:zip]).to eq("95101")
    end

    it "handles UNPARSEABLE ADDRESS prefix gracefully" do
      result = parser.parse("UNPARSEABLE ADDRESS: just a street name")
      expect(result).to be_a(Hash)
      expect(result[:parseable]).to eq(false)
    end

    it "marks truly unparseable addresses" do
      result = parser.parse("this is not an address at all")
      expect(result[:parseable]).to eq(false)
      expect(result[:address1]).to include("UNPARSEABLE ADDRESS")
    end

    it "parses address1, address2, city state zip (no comma before state)" do
      result = parser.parse("100 Main St, Suite 200, San Jose CA 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:address2]).to eq("Suite 200")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses address1, address2, city, state, zip with extra comma before zip" do
      result = parser.parse("100 Main St, Suite 200, San Jose, CA, 95101")
      expect(result[:address1]).to eq("100 Main St")
      expect(result[:address2]).to eq("Suite 200")
      expect(result[:city]).to eq("San Jose")
      expect(result[:state]).to eq("CA")
      expect(result[:zip]).to eq("95101")
    end

    it "parses hyphenated zip codes" do
      result = parser.parse("100 Main St, San Jose, CA 95101-1234")
      expect(result[:zip]).to eq("95101-1234")
    end

    it "parses address1 city. state zip (period between state and zip)" do
      result = parser.parse("100 Main St, San Jose CA. 95101")
      expect(result).to be_a(Hash)
    end
  end
end
