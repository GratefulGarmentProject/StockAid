require "rails_helper"

describe NetSuiteIntegration, type: :model do
  let(:donation) { donations(:unsynced_donation) }
  let(:order) { orders(:open_order) }
  let(:donor) { donors(:picard) }
  let(:organization) { organizations(:acme) }
  let(:vendor) { vendors(:guinan) }

  describe ".host" do
    it "returns a netsuite host string" do
      expect(NetSuiteIntegration.host).to be_a(String)
    end
  end

  describe ".path" do
    context "with a donation" do
      before { donation.update_column(:external_id, 42) }

      it "returns a cashsale URL" do
        expect(NetSuiteIntegration.path(donation)).to include("cashsale.nl")
      end

      it "returns a journal URL with journal prefix" do
        donation.update_column(:journal_external_id, 142)
        expect(NetSuiteIntegration.path(donation, prefix: :journal)).to include("journal.nl")
      end
    end

    context "with an order" do
      before { order.update_column(:external_id, 10) }

      it "returns a custinvc URL" do
        expect(NetSuiteIntegration.path(order)).to include("custinvc.nl")
      end

      it "returns a journal URL with journal prefix" do
        order.update_column(:journal_external_id, 11)
        expect(NetSuiteIntegration.path(order, prefix: :journal)).to include("journal.nl")
      end
    end

    context "with a donor (individual)" do
      before { donor.update_column(:external_id, 55) }

      it "returns a contact URL for individual donors" do
        donor.update_column(:external_type, "Individual")
        expect(NetSuiteIntegration.path(donor)).to include("contact.nl")
      end

      it "returns a custjob URL for non-individual donors" do
        donor.update_column(:external_type, "Organization")
        expect(NetSuiteIntegration.path(donor)).to include("custjob.nl")
      end
    end

    context "with an organization" do
      before { organization.update_column(:external_id, 77) }

      it "returns a custjob URL" do
        expect(NetSuiteIntegration.path(organization)).to include("custjob.nl")
      end
    end

    context "with a vendor" do
      before { vendor.update_column(:external_id, 88) }

      it "returns a vendor URL" do
        expect(NetSuiteIntegration.path(vendor)).to include("vendor.nl")
      end
    end

    context "with a purchase" do
      let(:purchase) { purchases(:received_purchase) }

      before { purchase.update_column(:external_id, 33) }

      it "returns a vendbill URL" do
        expect(NetSuiteIntegration.path(purchase)).to include("vendbill.nl")
      end

      it "returns a journal URL with variance prefix" do
        purchase.update_column(:variance_external_id, 34)
        expect(NetSuiteIntegration.path(purchase, prefix: :variance)).to include("journal.nl")
      end
    end
  end

  describe ".external_id_or_status_text" do
    it "returns nil when no external_id" do
      expect(NetSuiteIntegration.external_id_or_status_text(donation)).to be_nil
    end

    it "returns 'Export queued' when queued" do
      donation.update_column(:external_id, NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID)
      expect(NetSuiteIntegration.external_id_or_status_text(donation)).to eq("Export queued")
    end

    it "returns 'Export in progress' when in progress" do
      donation.update_column(:external_id, NetSuiteIntegration::EXPORT_IN_PROGRESS_EXTERNAL_ID)
      expect(NetSuiteIntegration.external_id_or_status_text(donation)).to eq("Export in progress")
    end

    it "returns 'Export failed!' when failed" do
      donation.update_column(:external_id, NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
      expect(NetSuiteIntegration.external_id_or_status_text(donation)).to eq("Export failed!")
    end

    it "returns 'N/A' when not applicable" do
      donation.update_column(:external_id, NetSuiteIntegration::EXPORT_NOT_APPLICABLE_EXTERNAL_ID)
      expect(NetSuiteIntegration.external_id_or_status_text(donation)).to eq("N/A")
    end

    it "returns the external_id when successfully exported" do
      donation.update_column(:external_id, 42)
      expect(NetSuiteIntegration.external_id_or_status_text(donation)).to eq(42)
    end
  end

  describe ".export_queued / .export_queued?" do
    it "marks an object as queued" do
      NetSuiteIntegration.export_queued(donation)
      expect(NetSuiteIntegration.export_queued?(donation)).to be true
    end
  end

  describe ".export_in_progress / .export_in_progress?" do
    it "marks an object as in progress" do
      NetSuiteIntegration.export_in_progress(donation)
      expect(NetSuiteIntegration.export_in_progress?(donation)).to be true
    end
  end

  describe ".export_failed / .export_failed?" do
    it "marks an object as failed" do
      NetSuiteIntegration.export_failed(donation)
      expect(NetSuiteIntegration.export_failed?(donation)).to be true
    end
  end

  describe ".export_not_applicable / .export_not_applicable?" do
    it "marks an object as not applicable" do
      NetSuiteIntegration.export_not_applicable(donation)
      expect(NetSuiteIntegration.export_not_applicable?(donation)).to be true
    end
  end

  describe ".exported_successfully?" do
    it "returns falsy when not exported" do
      expect(NetSuiteIntegration.exported_successfully?(donation)).to be_falsey
    end

    it "returns false when failed" do
      donation.update_column(:external_id, NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
      expect(NetSuiteIntegration.exported_successfully?(donation)).to be false
    end

    it "returns true when exported with positive id" do
      donation.update_column(:external_id, 42)
      expect(NetSuiteIntegration.exported_successfully?(donation)).to be true
    end

    it "returns true for not-applicable" do
      donation.update_column(:external_id, NetSuiteIntegration::EXPORT_NOT_APPLICABLE_EXTERNAL_ID)
      expect(NetSuiteIntegration.exported_successfully?(donation)).to be true
    end
  end

  describe ".exports_queued" do
    it "marks the base export and additional prefixes as queued" do
      donation.update_column(:journal_external_id, nil)
      NetSuiteIntegration.exports_queued(donation, additional_prefixes: [:journal])
      expect(NetSuiteIntegration.export_queued?(donation)).to be true
      expect(NetSuiteIntegration.export_queued?(donation, prefix: :journal)).to be true
    end

    it "skips already successful base exports" do
      donation.update_column(:external_id, 42)
      donation.update_column(:journal_external_id, nil)
      NetSuiteIntegration.exports_queued(donation, additional_prefixes: [:journal])
      expect(donation.reload.external_id).to eq(42)
      expect(NetSuiteIntegration.export_queued?(donation, prefix: :journal)).to be true
    end
  end

  describe ".exports_in_progress" do
    it "marks the base export and additional prefixes as in progress" do
      donation.update_column(:journal_external_id, nil)
      NetSuiteIntegration.exports_in_progress(donation, additional_prefixes: [:journal])
      expect(NetSuiteIntegration.export_in_progress?(donation)).to be true
      expect(NetSuiteIntegration.export_in_progress?(donation, prefix: :journal)).to be true
    end

    it "skips already successful base exports" do
      donation.update_column(:external_id, 42)
      donation.update_column(:journal_external_id, nil)
      NetSuiteIntegration.exports_in_progress(donation, additional_prefixes: [:journal])
      expect(donation.reload.external_id).to eq(42)
    end
  end

  describe ".exports_failed" do
    it "marks the base export and additional prefixes as failed" do
      donation.update_column(:journal_external_id, nil)
      NetSuiteIntegration.exports_failed(donation, additional_prefixes: [:journal])
      expect(NetSuiteIntegration.export_failed?(donation)).to be true
      expect(NetSuiteIntegration.export_failed?(donation, prefix: :journal)).to be true
    end

    it "skips already successful base exports" do
      donation.update_column(:external_id, 42)
      donation.update_column(:journal_external_id, nil)
      NetSuiteIntegration.exports_failed(donation, additional_prefixes: [:journal])
      expect(donation.reload.external_id).to eq(42)
    end
  end

  describe ".any_not_exported_successfully?" do
    it "returns true when base not exported" do
      expect(NetSuiteIntegration.any_not_exported_successfully?(donation, additional_prefixes: [:journal])).to be true
    end

    it "returns true when base exported but prefix not" do
      donation.update_column(:external_id, 42)
      donation.update_column(:journal_external_id, nil)
      expect(NetSuiteIntegration.any_not_exported_successfully?(donation, additional_prefixes: [:journal])).to be true
    end

    it "returns false when both exported" do
      donation.update_column(:external_id, 42)
      donation.update_column(:journal_external_id, 142)
      expect(NetSuiteIntegration.any_not_exported_successfully?(donation, additional_prefixes: [:journal])).to be false
    end
  end
end
