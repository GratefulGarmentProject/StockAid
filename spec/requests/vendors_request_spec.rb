require "rails_helper"

RSpec.describe VendorsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get vendors_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_vendor_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#edit" do
    it "renders ok" do
      get edit_vendor_path(vendors(:guinan))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a vendor and redirects" do
      post vendors_path, params: {
        vendor: {
          name: "New Test Vendor",
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to redirect_to(vendors_path)
      expect(flash[:success]).to be_present
      expect(Vendor.find_by(name: "New Test Vendor")).to be_present
    end

    it "re-renders new form with error when name is blank" do
      post vendors_path, params: {
        vendor: {
          name: "",
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to have_http_status(:ok)
      expect(flash[:error]).to be_present
    end
  end

  describe "#update" do
    let(:vendor) { vendors(:guinan) }

    it "updates and redirects" do
      patch vendor_path(vendor), params: {
        vendor: {
          name: "Updated Guinan",
          addresses_attributes: { "0" => { address: "" } }
        }
      }
      expect(response).to redirect_to(vendors_path)
      expect(vendor.reload.name).to eq("Updated Guinan")
    end
  end

  describe "#destroy" do
    it "soft deletes or errors and redirects" do
      delete vendor_path(vendors(:guinan))
      expect(response).to redirect_to(vendors_path)
    end
  end

  describe "#deleted" do
    it "renders ok" do
      get deleted_vendors_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#restore" do
    let(:vendor) { Vendor.create!(name: "Restore Test Vendor") }

    before { vendor.soft_delete }

    it "restores the vendor and redirects" do
      patch restore_vendor_path(vendor)
      expect(response).to have_http_status(:found)
      expect(vendor.reload.deleted_at).to be_nil
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get vendors_path }.to raise_error(PermissionError)
    end
  end
end
