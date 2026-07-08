require "rails_helper"

RSpec.describe RevenueStreamsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get revenue_streams_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders ok" do
      get revenue_stream_path(revenue_streams(:active_revenue_stream))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_revenue_stream_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a revenue stream and redirects" do
      expect {
        post revenue_streams_path, params: { revenue_stream: { name: "New Stream" } }
      }.to change(RevenueStream, :count).by(1)
      expect(response).to have_http_status(:found)
    end
  end

  describe "#update" do
    let(:stream) { revenue_streams(:active_revenue_stream) }

    it "updates and redirects" do
      patch revenue_stream_path(stream), params: { revenue_stream: { name: "Updated Stream" } }
      expect(response).to have_http_status(:found)
      expect(stream.reload.name).to eq("Updated Stream")
    end
  end

  describe "#destroy" do
    let(:stream) { RevenueStream.create!(name: "Deletable Stream") }

    it "soft deletes and redirects" do
      delete revenue_stream_path(stream)
      expect(response).to have_http_status(:found)
    end
  end

  describe "#deleted" do
    it "renders ok" do
      get deleted_revenue_streams_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#restore" do
    let(:stream) { revenue_streams(:deleted_revenue_stream) }

    it "restores and redirects" do
      patch restore_revenue_stream_path(stream)
      expect(response).to have_http_status(:found)
    end
  end
end
