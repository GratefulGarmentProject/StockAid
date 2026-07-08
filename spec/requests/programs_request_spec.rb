require "rails_helper"

RSpec.describe ProgramsController, type: :request do
  let(:super_admin) { users(:root) }

  before { sign_in super_admin }

  describe "#index" do
    it "renders ok" do
      get programs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#new" do
    it "renders ok" do
      get new_program_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "renders ok" do
      get program_path(programs(:resource_closets))
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a program and redirects" do
      post programs_path, params: {
        name: "Test Program",
        initialized_name: "TP",
        external_class_id: 99,
        external_id: 99
      }
      expect(response).to redirect_to(programs_path)
      expect(flash[:success]).to be_present
      expect(Program.find_by(initialized_name: "TP")).to be_present
    end

    context "with a duplicate initialized_name" do
      it "renders new with an error" do
        post programs_path, params: {
          name: "Resource Closets Dup",
          initialized_name: "RC",
          external_class_id: 100,
          external_id: 100
        }
        expect(response).to have_http_status(:ok)
        expect(flash.now[:error]).to be_present
      end
    end
  end

  describe "#update" do
    let(:program) { programs(:resource_closets) }

    it "updates and redirects" do
      patch program_path(program), params: {
        name: "Resource Closets Updated",
        initialized_name: program.initialized_name,
        external_class_id: program.external_class_id
      }
      expect(response).to redirect_to(programs_path)
      expect(flash[:success]).to be_present
      expect(program.reload.name).to eq("Resource Closets Updated")
    end
  end

  describe "permission check" do
    before { sign_in users(:acme_normal) }

    it "raises PermissionError for non-admin users" do
      expect { get programs_path }.to raise_error(PermissionError)
    end
  end
end
