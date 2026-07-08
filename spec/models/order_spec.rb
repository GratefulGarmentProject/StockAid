require "rails_helper"

describe Order do
  describe ".value" do
    it "has no value with no details" do
      order = Order.new
      expect(order.value).to eq(0.0)
    end

    it "has no value with details with no value" do
      order = Order.new
      order.order_details.build(quantity: 0, value: 5.0)
      order.order_details.build(quantity: 5, value: 0.0)
      expect(order.value).to eq(0.0)
    end

    it "value equal to all details full value" do
      order = Order.new
      order.order_details.build(quantity: 1, value: 5.0)
      order.order_details.build(quantity: 2, value: 2.0)
      order.order_details.build(quantity: 3, value: 3.0)
      expect(order.value).to eq(18.0)
    end
  end

  describe ".create_values_for_programs" do
    let(:order) { orders(:closed_order_with_order_details) }
    let(:acme) { organizations(:acme) }
    let(:resource_closets) { programs(:resource_closets) }
    let(:pack_it_forward) { programs(:pack_it_forward) }

    it "creates program details with proper split of values" do
      expect(order.order_program_details.size).to eq(0)
      order.create_values_for_programs
      order.reload
      order_values = order.value_by_program
      # 20 from small flip flops and 20 from large pants
      expect(order_values[resource_closets]).to eq(40.00)
      # 20 from large pants
      expect(order_values[pack_it_forward]).to eq(20.00)
    end

    it "doesn't include value from programs the organization is not part of" do
      acme.organization_programs.where(program: pack_it_forward).first.destroy
      order.create_values_for_programs
      order.reload
      order_values = order.value_by_program
      # Since no longer part of Pack-It-Forward, all goes to Resource Closets
      expect(order_values[resource_closets]).to eq(60.00)
      expect(order_values[pack_it_forward]).to be_nil
    end
  end

  describe "#required_surveys and #requires_survey_answers?" do
    let(:order) { orders(:open_order) }

    it "returns empty array when no items have surveys" do
      expect(order.required_surveys).to eq([])
    end

    it "returns false for requires_survey_answers? with no surveys" do
      expect(order.requires_survey_answers?).to eq(false)
    end
  end

  describe "#submitted?" do
    it "returns false for select_items status" do
      order = Order.new(status: :select_items)
      expect(order.submitted?).to eq(false)
    end

    it "returns true for pending status" do
      order = orders(:pending_order)
      expect(order.submitted?).to eq(true)
    end
  end

  describe "#open?" do
    it "returns true for pending orders" do
      order = orders(:pending_order)
      expect(order.open?).to eq(true)
    end

    it "returns false for closed orders" do
      order = orders(:closed_order)
      expect(order.open?).to eq(false)
    end
  end

  describe "#order_uneditable?" do
    it "returns false for pending orders" do
      order = orders(:pending_order)
      expect(order.order_uneditable?).to eq(false)
    end

    it "returns true for closed orders" do
      order = orders(:closed_order)
      expect(order.order_uneditable?).to eq(true)
    end
  end

  describe "#ship_to_addresses" do
    it "returns organization addresses" do
      order = orders(:open_order)
      expect(order.ship_to_addresses).to be_an(Array)
    end
  end

  describe "#ship_to_names" do
    it "returns user name options" do
      order = orders(:open_order)
      names = order.ship_to_names
      expect(names).to include(users(:root).name)
    end
  end

  describe "closing an order" do
    let(:order) { orders(:received_order_with_order_details) }
    let(:resource_closets) { programs(:resource_closets) }
    let(:pack_it_forward) { programs(:pack_it_forward) }

    it "creates values for programs" do
      order.update_status("close")
      order.save!
      order.reload
      order_values = order.value_by_program
      # 20 from small flip flops and 20 from large pants
      expect(order_values[resource_closets]).to eq(40.00)
      # 20 from large pants
      expect(order_values[pack_it_forward]).to eq(20.00)
    end

    it "markes the order's closed_at time" do
      expect(order.closed_at).to be_nil
      order.update_status("close")
      order.save!
      order.reload
      expect(order.closed_at).to be_present
    end

    it "starts a sync to netsuite" do
      expect(order.external_id).to be_nil

      expect do
        order.update_status("close")
        order.save!
      end.to have_enqueued_job(ExportOrderJob).with(order.id)

      order.reload
      expect(order.external_id).to eq(NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID)
    end
  end
end
