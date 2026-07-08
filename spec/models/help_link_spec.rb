require "rails_helper"

describe HelpLink, type: :model do
  describe ".for_users" do
    it "returns only visible links in ordering order" do
      links = HelpLink.for_users
      expect(links).to include(help_links(:first_link))
      expect(links).not_to include(help_links(:second_link))
      expect(links.map(&:ordering)).to eq(links.map(&:ordering).sort)
    end
  end

  describe ".for_editing" do
    it "returns all links in ordering order" do
      links = HelpLink.for_editing
      expect(links).to include(help_links(:first_link))
      expect(links).to include(help_links(:second_link))
      expect(links.map(&:ordering)).to eq(links.map(&:ordering).sort)
    end
  end

  describe "#move_up" do
    it "causes the link to appear earlier in the editing list" do
      second = help_links(:second_link)
      second.move_up
      expect(HelpLink.for_editing.first).to eq(second.reload)
    end
  end

  describe "#move_down" do
    it "causes the link to appear later in the editing list" do
      first = help_links(:first_link)
      first.move_down
      expect(HelpLink.for_editing.last).to eq(first.reload)
    end
  end
end
