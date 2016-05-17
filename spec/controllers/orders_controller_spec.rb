require "rails_helper"

describe OrdersController, type: :controller do
  describe "POST create" do
    it "creates an order assigned to the selected organization"
    it "fails if user isn't affiliated with selected organization"
    it "fails if organization doesn't exist"
    it "creates an order that contains items requested"
    it "fails if the quantity of an item requested is greater than available"
    it "fails if the quantity of an item requested is 0"
    it "fails if the quantity of an item requested is negative"
    it "fails if the same item is requested multiple times"
    it "fails if there is a partial item description"
  end
end
