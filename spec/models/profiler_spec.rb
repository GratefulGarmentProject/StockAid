require "rails_helper"

describe Profiler, type: :model do
  let(:session) { {} }

  describe ".enabled?" do
    it "returns false when profiler is not enabled" do
      expect(Profiler.enabled?(session)).to be false
    end

    it "returns true when profiler is enabled" do
      session[:profiler_enabled] = "true"
      expect(Profiler.enabled?(session)).to be true
    end
  end

  describe ".toggle_label" do
    it "returns 'Turn Off Profiling' when enabled" do
      session[:profiler_enabled] = "true"
      expect(Profiler.toggle_label(session)).to eq("Turn Off Profiling")
    end

    it "returns 'Turn On Profiling' when disabled" do
      expect(Profiler.toggle_label(session)).to eq("Turn On Profiling")
    end
  end

  describe ".toggle" do
    it "enables profiling when currently off and returns 'on'" do
      expect(Profiler.toggle(session)).to eq("on")
      expect(session[:profiler_enabled]).to eq("true")
    end

    it "disables profiling when currently on and returns 'off'" do
      session[:profiler_enabled] = "true"
      expect(Profiler.toggle(session)).to eq("off")
      expect(session[:profiler_enabled]).to eq("false")
    end
  end
end
