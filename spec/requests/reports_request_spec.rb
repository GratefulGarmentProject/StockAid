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

    it "fetches donors list when date range is provided" do
      get donor_receipts_reports_path, params: {
        report_start_date: 1.year.ago.strftime("%m/%d/%Y"),
        report_end_date: Time.current.strftime("%m/%d/%Y")
      }
      expect(response).to have_http_status(:ok)
    end

    it "renders receipts for donor with closed donations and details" do
      # donors(:riker) has unsynced_closed_donation_with_donor_with_county which has details
      get donor_receipts_reports_path, params: { "donor_ids[]" => donors(:riker).id }
      expect(response).to have_http_status(:ok)
    end

    it "renders receipts for an Organization-type donor" do
      # starfleet_command is external_type: Organization — exercises donor_first_name else branch
      # Must add details before closing (closed donations cannot be modified)
      open_donation = Donation.create!(
        donor: donors(:starfleet_command),
        user: users(:root),
        revenue_stream: revenue_streams(:active_revenue_stream),
        donation_date: Time.zone.now
      )
      open_donation.donation_details.create!(item: items(:small_flip_flops), quantity: 1, value: 10.0)
      open_donation.update_column(:closed_at, Time.zone.now)
      get donor_receipts_reports_path, params: { "donor_ids[]" => donors(:starfleet_command).id }
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
    let(:item) { items(:small_flip_flops) }
    let(:start_date) { 2.days.ago.strftime("%m/%d/%Y") }
    let(:end_date) { Time.current.strftime("%m/%d/%Y") }

    before do
      # Create PaperTrail versions for various edit_reasons to cover Row/CondensedRow
      PaperTrail.request.whodunnit = users(:root).id.to_s
      %w[adjustment spoilage reconciliation transfer_internal transfer_external].each do |reason|
        item.mark_event(edit_amount: "1", edit_method: "add", edit_reason: reason, edit_source: "spec")
        item.save!
      end
      %w[donation purchase order_adjustment donation_adjustment transfer
         purchase_shipment_received purchase_shipment_deleted].each do |reason|
        item.mark_event(edit_amount: "1", edit_method: "subtract", edit_reason: reason, edit_source: "spec")
        item.save!
      end
    end

    it "renders ok" do
      get inventory_adjustments_reports_path
      expect(response).to have_http_status(:ok)
    end

    it "returns CSV when requested with all data" do
      get inventory_adjustments_reports_path, params: {
        csv: "true",
        start_date: start_date,
        end_date: end_date
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end

    it "returns condensed CSV covering CondensedRow class" do
      get inventory_adjustments_reports_path, params: {
        csv: "true",
        start_date: start_date,
        end_date: end_date,
        style: "condensed"
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end

    it "returns filtered CSV covering short_reason_label for adjustment and spoilage" do
      get inventory_adjustments_reports_path, params: {
        csv: "true",
        start_date: start_date,
        end_date: end_date,
        reasons: %w[adjustment spoilage]
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end

    it "returns filtered CSV covering short_reason_label for transfer variants" do
      get inventory_adjustments_reports_path, params: {
        csv: "true",
        start_date: start_date,
        end_date: end_date,
        reasons: %w[transfer transfer_internal transfer_external]
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end

    it "returns filtered CSV covering short_reason_label for purchase variants" do
      get inventory_adjustments_reports_path, params: {
        csv: "true",
        start_date: start_date,
        end_date: end_date,
        reasons: %w[purchase purchase_shipment_received purchase_shipment_deleted]
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end

    it "returns filtered CSV covering short_reason_label for donation variants" do
      get inventory_adjustments_reports_path, params: {
        csv: "true",
        start_date: start_date,
        end_date: end_date,
        reasons: %w[donation donation_adjustment order_adjustment reconciliation]
      }
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

    it "returns CSV for a single category (SingleCategory branch)" do
      get total_inventory_value_reports_path, params: {
        csv: "true",
        category_id: categories(:flip_flops).id
      }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end
  end

  describe "#value_by_donor" do
    it "renders ok" do
      get value_by_donor_reports_path
      expect(response).to have_http_status(:ok)
    end

    it "renders ok with a specific donor (SingleDonor branch)" do
      get value_by_donor_reports_path, params: { donor: donors(:riker).id }
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
