require "rails_helper"

RSpec.describe "Programs", type: :request do
  context "when normal user logs in" do
    let!(:normal_user) { users(:acme_normal) }
    before { sign_in normal_user }
    describe "GET /programs" do
      it "raises permission error" do
        expect { get programs_path }.to raise_error(PermissionError)
      end
    end
    describe "POST /programs" do
      let(:valid_params) { { program: { name: "Socks for Tots" } } }
      it "raises permission error" do
        expect { post programs_path, params: valid_params }.to raise_error(PermissionError)
      end
    end
    describe "GET /programs/:id" do
      let(:program) { Program.create(name: "Socks for Tots") }
      it "raises permission error" do
        expect { get program_path(program) }.to raise_error(PermissionError)
      end
    end
    describe "PATCH /programs/:id" do
      let(:program) { Program.create(name: "Socks for Tots") }
      let(:valid_params) { { program: { name: "Socks for Juniors" } } }
      it "raises permission error" do
        expect { patch program_path(program), params: valid_params }.to raise_error(PermissionError)
      end
    end
    describe "DELETE /programs/:id" do
      let(:program) { Program.create(name: "Socks for Tots") }
      it "raises permission error" do
        expect { delete program_path(program) }.to raise_error(PermissionError)
      end
    end
  end
  context "when super admin user" do
    let!(:admin_user) { users(:root) }
    let!(:program1) { Program.create(name: "Resource Closets") }
    let!(:program2) { Program.create(name: "Human Trafficking/CSEC Resources") }
    let!(:program3) { Program.create(name: "Pack-It-Forward") }
    let!(:program4) { Program.create(name: "Youth Gift-Card/Incentive Program") }
    let!(:program5) { Program.create(name: "Dress for Dignity") }
    let!(:program6) { Program.create(name: "Beautification Projects") }

    before { sign_in admin_user }
    describe "GET /programs" do
      it "returns the index" do
        get programs_path
        expect(response).to have_http_status :ok
      end
    end
  end
end
