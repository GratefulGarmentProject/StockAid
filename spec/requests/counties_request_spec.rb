require "rails_helper"

RSpec.describe CountiesController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get counties_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_county_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a county and redirects" do
      post counties_path, params: { county: { name: "New Test County" } }
      expect(response).to redirect_to(counties_path)
      expect(flash[:success]).to be_present
      expect(County.find_by(name: "New Test County")).to be_present
    end

    it "re-renders new with error when external_id is a duplicate" do
      post counties_path, params: { county: { name: "Dup County", external_id: counties(:santa_clara).external_id } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash.now[:error]).to be_present
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_county_path(counties(:santa_clara))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    let(:county) { counties(:santa_clara) }

    it "updates and redirects" do
      patch county_path(county), params: { county: { name: "Santa Clara Updated" } }
      expect(response).to redirect_to(counties_path)
      expect(flash[:success]).to be_present
      expect(county.reload.name).to eq("Santa Clara Updated")
    end

    it "re-renders edit with error when external_id is a duplicate" do
      other_county = County.create!(name: "Other County", external_id: 999)
      patch county_path(other_county), params: { county: { name: other_county.name, external_id: county.external_id } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash.now[:error]).to be_present
    end
  end

  describe "#assigned" do
    it "returns JSON" do
      allow(NetSuiteIntegration::Region).to receive(:all).and_return([])
      get assigned_counties_path
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/json")
    end
  end

  describe "#unassigned" do
    it "renders ok" do
      allow(NetSuiteIntegration::Region).to receive(:all).and_return([])
      get unassigned_counties_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get counties_path }.to raise_error(PermissionError)
    end
  end
end
