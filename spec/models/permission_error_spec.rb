require "spec_helper"
require File.join(APP_ROOT, "models/permission_error")

describe PermissionError do
  let(:user) do
    double false_permission_1: false,
           false_permission_2: false,
           true_permission_1: true,
           true_permission_2: true
  end

  describe ".check" do
    context "with no permissions" do
      it "raises an ArgumentError" do
        expect { PermissionError.check(user) }.to raise_error(ArgumentError)
      end
    end

    context "with a single permission" do
      it "raises on false permission" do
        expect { PermissionError.check(user, :false_permission_1) }.to raise_error(PermissionError)
      end

      it "doesn't raise on true permission" do
        expect { PermissionError.check(user, :true_permission_1) }.to_not raise_error
      end
    end

    context "with several permissions" do
      it "raises if at least one of them fails" do
        expect { PermissionError.check(user, %i(true_permission_1 false_permission_1)) }
          .to raise_error(PermissionError)
        expect { PermissionError.check(user, %i(false_permission_1 true_permission_1)) }
          .to raise_error(PermissionError)
        expect { PermissionError.check(user, %i(false_permission_1 true_permission_1 false_permission_2)) }
          .to raise_error(PermissionError)
      end

      it "doesn't raise if all are true" do
        expect { PermissionError.check(user, %i(true_permission_1 true_permission_2)) }.to_not raise_error
      end
    end

    context "with one_of option" do
      it "raises if all fail" do
        expect { PermissionError.check(user, one_of: %i(false_permission_1 false_permission_2)) }
          .to raise_error(PermissionError)
      end

      it "doesn't raise if any are true" do
        expect { PermissionError.check(user, one_of: %i(true_permission_1 true_permission_2)) }.to_not raise_error
        expect { PermissionError.check(user, one_of: %i(true_permission_1 false_permission_1)) }.to_not raise_error
        expect { PermissionError.check(user, one_of: %i(false_permission_1 true_permission_1)) }.to_not raise_error
      end
    end
  end
end
