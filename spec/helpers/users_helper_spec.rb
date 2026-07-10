require "rails_helper"

RSpec.describe UsersHelper, type: :helper do
  describe "#additional_organizations_json" do
    it "returns JSON array of orgs beyond the first" do
      user = users(:root)
      orgs = [organizations(:acme), organizations(:foo_inc)]
      result = helper.additional_organizations_json(user, orgs)
      parsed = JSON.parse(result)
      expect(parsed).to be_an(Array)
      expect(parsed.length).to eq(1)
      expect(parsed.first["name"]).to eq(organizations(:foo_inc).name)
    end

    it "returns empty JSON array when only one org is given" do
      user = users(:root)
      orgs = [organizations(:acme)]
      result = helper.additional_organizations_json(user, orgs)
      expect(JSON.parse(result)).to eq([])
    end
  end
end
