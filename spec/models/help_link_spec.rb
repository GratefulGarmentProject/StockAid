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

  describe "#decrement_ordering" do
    it "decrements the ordering by 1 and saves" do
      link = HelpLink.create!(label: "Decrement Test", url: "https://example.com/dec", ordering: 50, visible: false)
      link.decrement_ordering
      expect(link.reload.ordering).to eq(49)
    end
  end

  describe "#increment_ordering" do
    it "increments the ordering by 1 and saves" do
      link = HelpLink.create!(label: "Increment Test", url: "https://example.com/inc", ordering: 100, visible: false)
      link.increment_ordering
      expect(link.reload.ordering).to eq(101)
    end
  end
end
