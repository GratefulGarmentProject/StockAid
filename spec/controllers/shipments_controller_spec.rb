require "rails_helper"

describe ShipmentsController, type: :controller do
  describe "GET #new" do
    it "returns http success" do
      signed_in_user :acme_normal
      get :new
      expect(response).to have_http_status(:success)
    end
  end
end
