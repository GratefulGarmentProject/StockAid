require "rails_helper"

RSpec.describe HelpLinksController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get help_links_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a help link and redirects" do
      post help_links_path, params: { label: "New Link", url: "https://newlink.example.com" }
      expect(response).to redirect_to(help_links_path)
      expect(flash[:success]).to be_present
      expect(HelpLink.find_by(label: "New Link")).to be_present
    end
  end

  describe "#destroy" do
    it "destroys a help link and redirects" do
      delete help_link_path(help_links(:first_link))
      expect(response).to redirect_to(help_links_path)
      expect(flash[:success]).to be_present
      expect(HelpLink.find_by(id: help_links(:first_link).id)).to be_nil
    end
  end

  describe "#toggle_visibility" do
    let(:link) { help_links(:first_link) }

    it "toggles the visibility and redirects" do
      original_visible = link.visible
      post toggle_visibility_help_link_path(link)
      expect(response).to redirect_to(help_links_path)
      expect(link.reload.visible).to eq(!original_visible)
    end
  end

  describe "#move_up" do
    it "moves the link up and redirects" do
      post move_up_help_link_path(help_links(:second_link))
      expect(response).to redirect_to(help_links_path)
    end
  end

  describe "#move_down" do
    it "moves the link down and redirects" do
      post move_down_help_link_path(help_links(:first_link))
      expect(response).to redirect_to(help_links_path)
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get help_links_path }.to raise_error(PermissionError)
    end
  end
end
