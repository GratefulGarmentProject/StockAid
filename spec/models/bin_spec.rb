require "rails_helper"

describe Bin, type: :model do
  it { should delegate_method(:rack).to(:bin_location) }
  it { should delegate_method(:shelf).to(:bin_location) }
end
