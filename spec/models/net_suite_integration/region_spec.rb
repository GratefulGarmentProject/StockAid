require "rails_helper"

describe NetSuiteIntegration::Region, type: :model do
  let(:region_record) { instance_double(NetSuite::Records::CustomRecord, internal_id: "55", name: "Santa Clara County") }
  let(:ca_region_record) { instance_double(NetSuite::Records::CustomRecord, internal_id: "1", name: "California") }
  let(:county) { counties(:santa_clara) }

  describe ".all" do
    it "returns an array of Region objects from search results" do
      allow(NetSuite::Records::CustomRecord).to receive(:search).and_return(
        double(results: [region_record])
      )
      regions = NetSuiteIntegration::Region.all
      expect(regions).to all(be_a(NetSuiteIntegration::Region))
      expect(regions.length).to eq(1)
    end

    it "returns empty array on error" do
      allow(NetSuite::Records::CustomRecord).to receive(:search).and_raise(StandardError, "connection refused")
      expect(NetSuiteIntegration::Region.all).to eq([])
    end
  end

  describe ".find" do
    context "with a county name" do
      it "returns a Region using the county name search" do
        allow(NetSuite::Records::CustomRecord).to receive(:search) do |args|
          basic = args[:basic]
          name_criterion = basic.find { |b| b[:field] == "name" }
          if name_criterion && name_criterion[:value].include?("Santa Clara")
            double(results: [region_record])
          else
            double(results: [ca_region_record])
          end
        end
        region = NetSuiteIntegration::Region.find("Santa Clara")
        expect(region).to be_a(NetSuiteIntegration::Region)
        expect(region.netsuite_id).to eq("55")
      end
    end

    context "with no county name (falls back to California)" do
      it "returns a Region for California" do
        allow(NetSuite::Records::CustomRecord).to receive(:search).and_return(
          double(results: [ca_region_record])
        )
        region = NetSuiteIntegration::Region.find(nil)
        expect(region.netsuite_id).to eq("1")
      end
    end
  end

  describe ".find_default" do
    it "returns a Region" do
      allow(NetSuite::Records::CustomRecord).to receive(:search).and_return(
        double(results: [ca_region_record])
      )
      expect(NetSuiteIntegration::Region.find_default).to be_a(NetSuiteIntegration::Region)
    end
  end

  describe ".from_county" do
    it "creates a Region from a county record" do
      region = NetSuiteIntegration::Region.from_county(county)
      expect(region).to be_a(NetSuiteIntegration::Region)
      expect(region.county_name).to eq(county.name)
      expect(region.netsuite_id).to eq(county.external_id)
    end
  end

  describe "#county_name" do
    it "returns the county name from the record" do
      region = NetSuiteIntegration::Region.new("Santa Clara", region_record)
      expect(region.county_name).to eq("Santa Clara")
    end

    it "falls back to county name when built from county" do
      region = NetSuiteIntegration::Region.from_county(county)
      expect(region.county_name).to eq(county.name)
    end
  end

  describe "#netsuite_id" do
    it "returns the region record internal_id" do
      region = NetSuiteIntegration::Region.new("Santa Clara", region_record)
      expect(region.netsuite_id).to eq("55")
    end

    it "falls back to county external_id when built from county" do
      region = NetSuiteIntegration::Region.from_county(county)
      expect(region.netsuite_id).to eq(county.external_id)
    end
  end

  describe "#netsuite_id_int" do
    it "returns the netsuite_id as an integer" do
      region = NetSuiteIntegration::Region.new("Santa Clara", region_record)
      expect(region.netsuite_id_int).to eq(55)
    end
  end

  describe "#assign_to" do
    it "assigns the region to a netsuite record's custom field" do
      region = NetSuiteIntegration::Region.new("Santa Clara", region_record)
      netsuite_record = NetSuite::Records::CashSale.new
      region.assign_to(netsuite_record)
      expect(netsuite_record.custom_field_list.custcol_cseg_npo_region.value.internal_id).to eq("55")
    end

    it "does nothing when there is no netsuite_id" do
      region = NetSuiteIntegration::Region.new(nil, nil)
      netsuite_record = NetSuite::Records::CashSale.new
      expect { region.assign_to(netsuite_record) }.not_to raise_error
    end
  end

  describe "#to_h" do
    it "returns a hash with external_id and name" do
      region = NetSuiteIntegration::Region.new("Santa Clara", region_record)
      expect(region.to_h).to eq(external_id: 55, name: "Santa Clara")
    end
  end
end
