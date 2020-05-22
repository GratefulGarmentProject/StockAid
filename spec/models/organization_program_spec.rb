require "rails_helper"

RSpec.describe OrganizationProgram, type: :model do
  let!(:program1) { Program.create(name: "Resource Closets") }
  let!(:program2) { Program.create(name: "Human Trafficking/CSEC Resources") }
  let!(:program3) { Program.create(name: "Pack-It-Forward") }
  let!(:program4) { Program.create(name: "Youth Gift-Card/Incentive Program") }
  let!(:program5) { Program.create(name: "Dress for Dignity") }
  let!(:program6) { Program.create(name: "Beautification Projects") }
  describe "managing the default program for an organization" do
    describe "able to change default program to another program for the organization" do
      let!(:org) { Organization.create(name: "Org with several programs") }
      before do
        org.programs << program1
        org.programs << program2
        org.programs << program3
        org.programs << program4
        org.programs << program5
        org.save!
        org.default_program = program1
      end
      it "changes the default program as requested" do
        expect(org.default_program).to eq(program1)
        expect((org.default_program = program2)).to eq(program2)
        expect(org.default_program).to eq(program2)
      end
      it "will not allow a program not associated with the organization to become the default" do
        expect { org.default_program = program6 }.to raise_error(ActiveRecord::RecordNotFound)
        expect(org.default_program).to eq(program1)
      end
    end
    describe "it is possible for an organization not to have a default program" do
      let!(:org_no_default) { Organization.create(name: "Org with no default program") }
      before do
        org_no_default.programs << program1
        org_no_default.save!
      end
      it "returns nil for default program" do
        expect(org_no_default.default_program).to be_nil
      end
      it "able to set a default program when no default program has been set" do
        expect((org_no_default.default_program = program1)).to eq(program1)
        expect(org_no_default.default_program).to eq(program1)
      end
    end
  end
end
