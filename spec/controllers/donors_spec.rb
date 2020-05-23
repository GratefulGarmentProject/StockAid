require "rails_helper"

describe DonorsController, type: :controller do
  let(:donor1) { donors(:starfleet_command) }
  let(:donor2) { donors(:picard) }
  let(:donor3) { donors(:riker) }
  let(:donor4) { donors(:troi) }

  describe "GET#index" do
    it "returns the correct variables" do
      signed_in_user :root

      get :index

      expect(assigns(:donors)).to eq([donor1, donor2, donor3, donor4])
    end

    context "when there are deleted items in the category" do
      it "does not include deleted items" do
        donor1.soft_delete

        signed_in_user :root
        get :index

        expect(assigns(:donors)).to eq([donor2, donor3, donor4])
      end
    end
  end

  describe "GET#deleted items" do
    it "returns the correct items" do
      donor1.soft_delete

      signed_in_user :root
      get :deleted

      expect(assigns(:donors)).to eq([donor1])
    end
  end
end
