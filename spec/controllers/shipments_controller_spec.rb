require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do

  describe "GET #create" do
    it "returns http success" do
      get :create
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #track" do
    it "returns http success" do
      get :track
      expect(response).to have_http_status(:success)
    end
  end

end
