require "rails_helper"

RSpec.describe ReportsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#donor_receipts" do
    it "renders ok without params" do
      get donor_receipts_reports_path
      expect(response).to have_http_status(:ok)
    end

    it "renders ok with donor_ids" do
      get donor_receipts_reports_path, params: { "donor_ids[]" => donors(:picard).id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#graphs" do
    it "renders ok" do
      get graphs_reports_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#inventory_adjustments" do
    it "renders ok" do
      get inventory_adjustments_reports_path
      expect(response).to have_http_status(:ok)
    end

    it "returns CSV when requested" do
      get inventory_adjustments_reports_path, params: { csv: "true" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end
  end

  describe "#total_inventory_value" do
    it "renders ok" do
      get total_inventory_value_reports_path
      expect(response).to have_http_status(:ok)
    end

    it "returns CSV when requested" do
      get total_inventory_value_reports_path, params: { csv: "true" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end
  end

  describe "#value_by_donor" do
    it "renders ok" do
      get value_by_donor_reports_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#value_by_county" do
    it "renders ok without params" do
      get value_by_county_reports_path
      expect(response).to have_http_status(:ok)
    end

    it "renders ok with a county filter" do
      county = Organization.counties.compact.first
      get value_by_county_reports_path, params: { county: county }
      expect(response).to have_http_status(:ok)
    end

    it "renders ok with all_orgs filter" do
      get value_by_county_reports_path, params: { all_orgs: "true" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#price_point_variance" do
    it "renders ok without params" do
      get price_point_variance_reports_path
      expect(response).to have_http_status(:ok)
    end

    it "renders ok with a vendor_id filter" do
      get price_point_variance_reports_path, params: { vendor_id: vendors(:guinan).id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#net_suite_export" do
    it "redirects when no records are present" do
      allow_any_instance_of(Reports::NetSuite::BaseExport).to receive(:build).and_return(
        double(records_present?: false)
      )
      get net_suite_export_reports_path, params: { report_type: "donations" }
      expect(response).to have_http_status(:found)
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get graphs_reports_path }.to raise_error(PermissionError)
    end
  end
end
