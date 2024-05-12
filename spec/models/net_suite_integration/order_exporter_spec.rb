require "rails_helper"

describe NetSuiteIntegration::OrderExporter, type: :model do
  include ActiveJob::TestHelper

  let(:region_record_double) { instance_double(NetSuite::Records::CustomRecord, internal_id: 444) }

  before do
    allow(NetSuiteIntegration::Region).to receive(:find).with(any_args).and_return(NetSuiteIntegration::Region.new("California", region_record_double))
  end

  context "with an order that is not ready to be synced" do
    let(:order) { orders(:open_order) }

    it "won't sync" do
      expect_any_instance_of(NetSuite::Records::Invoice).not_to receive(:add)
      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)
      exporter = NetSuiteIntegration::OrderExporter.new(order)
      expect { exporter.export }.to raise_error(/should not be synced/)
    end
  end

  context "with an already synced order" do
    let(:order) { orders(:fully_synced_order) }

    it "won't sync" do
      expect_any_instance_of(NetSuite::Records::Invoice).not_to receive(:add)
      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)
      exporter = NetSuiteIntegration::OrderExporter.new(order)
      expect { exporter.export }.to raise_error(/should not be synced/)
    end
  end

  context "with an order ready for syncing" do
    let(:order) { orders(:unsynced_order) }

    it "will sync" do
      expect_any_instance_of(NetSuite::Records::Invoice).to receive(:add) do |invoice|
        allow(invoice).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      exporter = NetSuiteIntegration::OrderExporter.new(order)
      exporter.export
      expect(order.external_id).to eq(42)
      expect(order.journal_external_id).to eq(142)
    end

    it "can be synced later" do
      expect_any_instance_of(NetSuite::Records::Invoice).to receive(:add) do |invoice|
        allow(invoice).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::OrderExporter.new(order).export_later
      end

      order.reload
      expect(order.external_id).to eq(42)
      expect(order.journal_external_id).to eq(142)
    end

    it "can have the invoice fail" do
      expect_any_instance_of(NetSuite::Records::Invoice).to receive(:add) do |invoice|
        allow(invoice).to receive(:internal_id).and_return("42")
        false
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)

      perform_enqueued_jobs do
        NetSuiteIntegration::OrderExporter.new(order).export_later
      end

      order.reload
      expect(order.external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
      expect(order.journal_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end

    it "can have the journal entry fail" do
      expect_any_instance_of(NetSuite::Records::Invoice).to receive(:add) do |invoice|
        allow(invoice).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        false
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::OrderExporter.new(order).export_later
      end

      order.reload
      expect(order.external_id).to eq(42)
      expect(order.journal_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end
  end

  context "with an order that was synced before journal entry syncing was a thing" do
    it "will sync the journal entry but not the invoice"
    it "can be synced later"
    it "can have the journal entry fail"
  end

  context "with an order that is being closed" do
    it "syncs the order"
  end
end
