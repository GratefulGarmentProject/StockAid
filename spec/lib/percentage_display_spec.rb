require "rails_helper"

describe PercentageDisplay do
  let(:logger) { double("logger", info: nil) }

  subject(:display) { described_class.new(total: 10, logger: logger) }

  it "starts at 0 count and 0 percent" do
    expect(display.current_count).to eq(0)
  end

  describe "#increment_counter" do
    it "increments by 1 by default" do
      display.increment_counter
      expect(display.current_count).to eq(1)
    end

    it "increments by a given amount" do
      display.increment_counter(3)
      expect(display.current_count).to eq(3)
    end
  end

  describe "#update_percentage" do
    it "logs progress when crossing a new percent threshold" do
      display.increment_counter(5)
      expect(logger).to receive(:info).with(/ done/)
      display.update_percentage
    end

    it "does not log when percentage has not advanced" do
      expect(logger).not_to receive(:info)
      display.update_percentage
    end

    it "does not log twice for the same percentage" do
      display.increment_counter(5)
      display.update_percentage
      expect(logger).not_to receive(:info)
      display.update_percentage
    end
  end
end
