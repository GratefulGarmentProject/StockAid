require "rails_helper"

describe DonorsController, type: :controller do
  let(:donor1) { donors(:starfleet_command) }
  let(:donor2) { donors(:picard) }
  let(:donor3) { donors(:riker) }
  let(:donor4) { donors(:troi) }

  describe "GET#index" do
    it "returns all existing donors" do
      signed_in_user :root
      get :index

      expect(assigns(:donors)).to include(donor1, donor2, donor3, donor4)
    end

    it "does not include deleted donors" do
      donor1.soft_delete

      signed_in_user :root
      get :index

      expect(assigns(:donors)).to include(donor2, donor3, donor4)
    end
  end

  describe "PATCH#update" do
    context "when user is a superuser" do
      it "is able to update all fields" do
        new_params = { id: donor1.id, donor: {
          name: "foo", primary_number: "1", secondary_number: "2", email: "bar",
          external_id: 9999, external_type: "Individual",
          addresses_attributes: { "0" => { address: "" } }
        } }

        expect(donor1.name).to             eq("Starfleet Command")
        expect(donor1.primary_number).to   eq("(510) 555-1111")
        expect(donor1.secondary_number).to eq("(510) 555-1112")
        expect(donor1.email).to            eq("info@starfleet.com")
        expect(donor1.external_id).to      eq(1)
        expect(donor1.external_type).to    eq("Organization")

        signed_in_user :root
        put :update, new_params

        donor1.reload
        expect(donor1.name).to             eq("foo")
        expect(donor1.primary_number).to   eq("1")
        expect(donor1.secondary_number).to eq("2")
        expect(donor1.email).to            eq("bar")
        expect(donor1.external_id).to      eq(9999)
        expect(donor1.external_type).to    eq("Individual")
      end
    end

    context "when user is _not_ a superuser" do
      it "fails due to permissions" do
        signed_in_user :acme_root

        expect do
          put :update, params: { id: donor1.id, donor: { name: "Foo" } }
        end.to raise_error(PermissionError)
      end
    end
  end

  describe "GET#deleted" do
    it "returns the correct donors" do
      donor1.soft_delete

      signed_in_user :root
      get :deleted

      expect(assigns(:donors)).to eq([donor1])
    end
  end
end
