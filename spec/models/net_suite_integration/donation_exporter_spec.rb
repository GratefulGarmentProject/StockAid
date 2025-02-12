require "rails_helper"

describe NetSuiteIntegration::DonationExporter, type: :model do
  include ActiveJob::TestHelper

  let(:region_record_double) { instance_double(NetSuite::Records::CustomRecord, internal_id: 444) }

  before do
    allow(NetSuiteIntegration::Region).to receive(:find).with(any_args).and_return(NetSuiteIntegration::Region.new("California", region_record_double))
  end

  context "with a donation that is not ready to be synced" do
    let(:donation) { donations(:open_donation) }

    it "won't sync" do
      expect_any_instance_of(NetSuite::Records::CashSale).not_to receive(:add)
      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)
      exporter = NetSuiteIntegration::DonationExporter.new(donation)
      expect { exporter.export }.to raise_error(/should not be synced/)
    end
  end

  context "with an already synced donation" do
    let(:donation) { donations(:fully_synced_donation) }

    it "won't sync" do
      expect_any_instance_of(NetSuite::Records::CashSale).not_to receive(:add)
      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)
      exporter = NetSuiteIntegration::DonationExporter.new(donation)
      expect { exporter.export }.to raise_error(/should not be synced/)
    end
  end

  context "with a donation ready for syncing" do
    let(:donation) { donations(:unsynced_donation) }

    it "will sync" do
      expect_any_instance_of(NetSuite::Records::CashSale).to receive(:add) do |cash_sale|
        allow(cash_sale).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      exporter = NetSuiteIntegration::DonationExporter.new(donation)
      exporter.export
      expect(donation.external_id).to eq(42)
      expect(donation.journal_external_id).to eq(142)
    end

    it "can be synced later" do
      expect_any_instance_of(NetSuite::Records::CashSale).to receive(:add) do |cash_sale|
        allow(cash_sale).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::DonationExporter.new(donation).export_later
      end

      donation.reload
      expect(donation.external_id).to eq(42)
      expect(donation.journal_external_id).to eq(142)
    end

    it "can have the cash sale fail" do
      expect_any_instance_of(NetSuite::Records::CashSale).to receive(:add) do |cash_sale|
        allow(cash_sale).to receive(:internal_id).and_return("42")
        false
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).not_to receive(:add)

      perform_enqueued_jobs do
        NetSuiteIntegration::DonationExporter.new(donation).export_later
      end

      donation.reload
      expect(donation.external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
      expect(donation.journal_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end

    it "can have the journal entry fail" do
      expect_any_instance_of(NetSuite::Records::CashSale).to receive(:add) do |cash_sale|
        allow(cash_sale).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        false
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::DonationExporter.new(donation).export_later
      end

      donation.reload
      expect(donation.external_id).to eq(42)
      expect(donation.journal_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end
  end

  context "with a donation that was synced before variance syncing was a thing" do
    let(:donation) { donations(:partial_synced_donation) }

    it "will sync the variance but not the donation" do
      external_id = donation.external_id
      expect_any_instance_of(NetSuite::Records::CashSale).not_to receive(:add)

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      exporter = NetSuiteIntegration::DonationExporter.new(donation)
      exporter.export
      expect(donation.external_id).to eq(external_id)
      expect(donation.journal_external_id).to eq(142)
    end

    it "can be synced later" do
      external_id = donation.external_id
      expect_any_instance_of(NetSuite::Records::CashSale).not_to receive(:add)

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::DonationExporter.new(donation).export_later
      end

      donation.reload
      expect(donation.external_id).to eq(external_id)
      expect(donation.journal_external_id).to eq(142)
    end

    it "can have the journal entry fail" do
      external_id = donation.external_id
      expect_any_instance_of(NetSuite::Records::CashSale).not_to receive(:add)

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        false
      end.once

      perform_enqueued_jobs do
        NetSuiteIntegration::DonationExporter.new(donation).export_later
      end

      donation.reload
      expect(donation.external_id).to eq(external_id)
      expect(donation.journal_external_id).to eq(NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID)
    end
  end

  context "with a donation that is being closed" do
    let(:donation) { donations(:open_donation) }
    let(:county) { counties(:santa_clara) }

    it "syncs the donation" do
      expect_any_instance_of(NetSuite::Records::CashSale).to receive(:add) do |cash_sale|
        allow(cash_sale).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        donation.close
      end

      donation.reload
      expect(donation.external_id).to eq(42)
      expect(donation.journal_external_id).to eq(142)
    end

    it "has the California NetSuite region ID when the donation doesn't have a county" do
      actual_cash_sale = nil
      actual_journal_entry = nil

      expect_any_instance_of(NetSuite::Records::CashSale).to receive(:add) do |cash_sale|
        actual_cash_sale = cash_sale
        allow(cash_sale).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        actual_journal_entry = journal_entry
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        donation.close
      end

      expect(actual_cash_sale.item_list.items.size).to be > 0
      expect(actual_journal_entry.line_list.lines.size).to be > 0

      actual_cash_sale.item_list.items.each do |item|
        expect(item.custom_field_list.custcol_cseg_npo_region.value.internal_id).to eq(444)
      end

      actual_journal_entry.line_list.lines.each do |line|
        expect(line.custom_field_list.custcol_cseg_npo_region.value.internal_id).to eq(444)
      end
    end

    it "has the proper NetSuite region ID when the donation has a county" do
      expect(county.external_id).to eq(42)
      donation.update!(county: county)
      actual_cash_sale = nil
      actual_journal_entry = nil

      expect_any_instance_of(NetSuite::Records::CashSale).to receive(:add) do |cash_sale|
        actual_cash_sale = cash_sale
        allow(cash_sale).to receive(:internal_id).and_return("42")
        true
      end.once

      expect_any_instance_of(NetSuite::Records::JournalEntry).to receive(:add) do |journal_entry|
        actual_journal_entry = journal_entry
        allow(journal_entry).to receive(:internal_id).and_return("142")
        true
      end.once

      perform_enqueued_jobs do
        donation.close
      end

      expect(actual_cash_sale.item_list.items.size).to be > 0
      expect(actual_journal_entry.line_list.lines.size).to be > 0

      actual_cash_sale.item_list.items.each do |item|
        expect(item.custom_field_list.custcol_cseg_npo_region.value.internal_id).to eq(42)
      end

      actual_journal_entry.line_list.lines.each do |line|
        expect(line.custom_field_list.custcol_cseg_npo_region.value.internal_id).to eq(42)
      end
    end
  end
end
