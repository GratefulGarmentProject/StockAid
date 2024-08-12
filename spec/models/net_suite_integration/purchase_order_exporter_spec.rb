require "rails_helper"

describe NetSuiteIntegration::PurchaseOrderExporter, type: :model do
  include ActiveJob::TestHelper

  let(:region_record_double) { instance_double(NetSuite::Records::CustomRecord, internal_id: 444) }

  before do
    allow(NetSuiteIntegration::Region).to receive(:find).with(any_args).and_return(NetSuiteIntegration::Region.new("California", region_record_double))
  end

  context "with a purchase that is not ready to be synced" do
    let(:purchase) { purchases(:purchase_with_details_and_shipments) }

    it "won't sync" do
      expect_any_instance_of(NetSuite::Records::VendorBill).not_to receive(:add)
      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)
      exporter = NetSuiteIntegration::PurchaseOrderExporter.new(purchase)
      expect { exporter.export }.to raise_error(/should not be synced/)
    end
  end

  context "with an already synced purchase" do
    let(:purchase) { purchases(:fully_synced_purchase) }

    it "won't sync" do
      expect_any_instance_of(NetSuite::Records::VendorBill).not_to receive(:add)
      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)
      exporter = NetSuiteIntegration::PurchaseOrderExporter.new(purchase)
      expect { exporter.export }.to raise_error(/should not be synced/)
    end
  end

  context "with a purchase ready for syncing" do
    let(:purchase) { purchases(:unsynced_purchase) }

    context "with no price point variance" do
      let(:purchase) { purchases(:unsynced_zero_ppv_purchase) }

      it "marks the journal as N/A" do
        expect(purchase.total_ppv).to eq(0)

        expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
          allow(vendor_bill).to receive(:internal_id).and_return("42")
          true
        end.once

        expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)
        exporter = NetSuiteIntegration::PurchaseOrderExporter.new(purchase)
        exporter.export
        expect(purchase.external_id).to eq(42)
        expect(purchase.variance_external_id).to eq(NetSuiteIntegration::EXPORT_NOT_APPLICABLE_EXTERNAL_ID)
      end

      it "marks the journal as N/A when synced later" do
        expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
          allow(vendor_bill).to receive(:internal_id).and_return("42")
          true
        end.once

        expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)

        perform_enqueued_jobs do
          NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export_later
        end

        purchase.reload
        expect(purchase.external_id).to eq(42)
        expect(purchase.variance_external_id).to eq(NetSuiteIntegration::EXPORT_NOT_APPLICABLE_EXTERNAL_ID)
      end
    end

    context "with a negative price point variance" do
      let(:purchase) { purchases(:unsynced_negative_ppv_purchase) }

      it "synces the right journal values" do
        expect(purchase.total_ppv).to eq(-6.48)
        synced_journal_entry = nil

        expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
          allow(vendor_bill).to receive(:internal_id).and_return("42")
          true
        end.once

        expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
          allow(journal_entry).to receive(:internal_id).and_return("142")
          synced_journal_entry = journal_entry
          true
        end.once

        exporter = NetSuiteIntegration::PurchaseOrderExporter.new(purchase)
        exporter.export
        expect(synced_journal_entry.line_list.lines.first.account.internal_id).to eq(NetSuiteIntegration::PurchaseOrderExporter::PPV_ACCOUNT_ID)
        expect(synced_journal_entry.line_list.lines.first.debit).to be_nil
        expect(synced_journal_entry.line_list.lines.first.credit).to eq(6.48)
        expect(synced_journal_entry.line_list.lines.last.account.internal_id).to eq(NetSuiteIntegration::PurchaseOrderExporter::INVENTORY_ASSET_ACCOUNT_ID)
        expect(synced_journal_entry.line_list.lines.last.debit).to eq(6.48)
        expect(synced_journal_entry.line_list.lines.last.credit).to be_nil
      end
    end

    context "with a positive price point variance" do
      let(:purchase) { purchases(:unsynced_positive_ppv_purchase) }

      it "synces the right journal values" do
        expect(purchase.total_ppv).to eq(5.64)
        synced_journal_entry = nil

        expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
          allow(vendor_bill).to receive(:internal_id).and_return("42")
          true
        end.once

        expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
          allow(journal_entry).to receive(:internal_id).and_return("142")
          synced_journal_entry = journal_entry
          true
        end.once

        exporter = NetSuiteIntegration::PurchaseOrderExporter.new(purchase)
        exporter.export
        expect(synced_journal_entry.line_list.lines.first.account.internal_id).to eq(NetSuiteIntegration::PurchaseOrderExporter::PPV_ACCOUNT_ID)
        expect(synced_journal_entry.line_list.lines.first.debit).to eq(5.64)
        expect(synced_journal_entry.line_list.lines.first.credit).to be_nil
        expect(synced_journal_entry.line_list.lines.last.account.internal_id).to eq(NetSuiteIntegration::PurchaseOrderExporter::INVENTORY_ASSET_ACCOUNT_ID)
        expect(synced_journal_entry.line_list.lines.last.debit).to be_nil
        expect(synced_journal_entry.line_list.lines.last.credit).to eq(5.64)
      end
    end

    it "will sync" do
      expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
        allow(vendor_bill).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      exporter = NetSuiteIntegration::PurchaseOrderExporter.new(purchase)
      exporter.export
      expect(purchase.external_id).to eq(42)
      expect(purchase.variance_external_id).to eq(142)
    end

    it "can be synced later" do
      expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
        allow(vendor_bill).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export_later
      end

      purchase.reload
      expect(purchase.external_id).to eq(42)
      expect(purchase.variance_external_id).to eq(142)
    end

    it "can have the vendor bill fail" do
      expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
        allow(vendor_bill).to receive(:internal_id).and_return("42")
        false
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)

      perform_enqueued_jobs do
        NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export_later
      end

      purchase.reload
      expect(purchase.external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
      expect(purchase.variance_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end

    it "can have the journal entry fail" do
      expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
        allow(vendor_bill).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        false
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export_later
      end

      purchase.reload
      expect(purchase.external_id).to eq(42)
      expect(purchase.variance_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end
  end

  context "with a purchase that was synced before variance syncing was a thing" do
    let(:purchase) { purchases(:partial_synced_purchase) }

    it "will sync the variance but not the purchase" do
      external_id = purchase.external_id
      expect_any_instance_of(NetSuite::Records::VendorBill).not_to receive(:add)

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      exporter = NetSuiteIntegration::PurchaseOrderExporter.new(purchase)
      exporter.export
      expect(purchase.external_id).to eq(external_id)
      expect(purchase.variance_external_id).to eq(142)
    end

    it "can be synced later" do
      external_id = purchase.external_id
      expect_any_instance_of(NetSuite::Records::VendorBill).not_to receive(:add)

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export_later
      end

      purchase.reload
      expect(purchase.external_id).to eq(external_id)
      expect(purchase.variance_external_id).to eq(142)
    end

    it "can have the journal entry fail" do
      external_id = purchase.external_id
      expect_any_instance_of(NetSuite::Records::VendorBill).not_to receive(:add)

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        false
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::PurchaseOrderExporter.new(purchase).export_later
      end

      purchase.reload
      expect(purchase.external_id).to eq(external_id)
      expect(purchase.variance_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end
  end

  context "with a purchase that is being closed" do
    let(:purchase) { purchases(:received_purchase) }

    it "syncs the purchase order" do
      expect_any_instance_of(NetSuite::Records::VendorBill).to receive(:add) do |vendor_bill|
        allow(vendor_bill).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        purchase.update_status("complete_purchase")
      end

      purchase.reload
      expect(purchase.external_id).to eq(42)
      expect(purchase.variance_external_id).to eq(142)
    end
  end
end
