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
      let!(:org) do
        org = Organization.create(name: "Org with several programs")
        org.programs << program1
        org.programs << program2
        org.programs << program3
        org.programs << program4
        org.programs << program5
        org.save!
        org.default_program = program1
        org
      end
      it "changes the default program as requested" do
        aggregate_failures do
          expect(org.default_program).to eq(program1)
          expect((org.default_program = program2)).to eq(program2)
          expect(org.default_program).to eq(program2)
        end
      end
      it "will not allow a program not associated with the organization to become the default" do
        aggregate_failures do
          expect { org.default_program = program6 }.to raise_error(ActiveRecord::RecordNotFound)
          expect(org.default_program).to eq(program1)
        end
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
        aggregate_failures do
          expect((org_no_default.default_program = program1)).to eq(program1)
          expect(org_no_default.default_program).to eq(program1)
        end
      end
    end
    describe "destroying a program that is an organization's default leaves the org with no default but raises no errors" do
      let!(:org) do
        org = Organization.create(name: "Org with several programs")
        org.programs << program1
        org.programs << program2
        org.programs << program3
        org.save!
        org.default_program = program1
        org
      end
      let!(:save_program_id) { org.default_program.id }
      before { org.default_program.destroy }
      it "should have no default program after program destroyed" do
        expect(org.default_program).to be_nil
      end
      it "there will be no other associations after program destroyed" do
        expect(OrganizationProgram.where(program_id: save_program_id)).to be_empty
      end
    end
  end
end
