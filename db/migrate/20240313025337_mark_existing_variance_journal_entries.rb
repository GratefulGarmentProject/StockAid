class MarkExistingVarianceJournalEntries < ActiveRecord::Migration[5.2]
  def up
    return unless Rails.env.production?

    set_variance_external_id(expected_amount:  "-889.67", entry: "JE2590", journal_id: 79254, from: "07/01/2021", to: "09/30/2021")
    set_variance_external_id(expected_amount:  "-531.00", entry: "JE2591", journal_id: 79255, from: "10/01/2021", to: "12/31/2021")
    set_variance_external_id(expected_amount:  "-337.40", entry: "JE2592", journal_id: 79256, from: "04/01/2022", to: "06/30/2022")
    set_variance_external_id(expected_amount: "-2219.49", entry: "JE2589", journal_id: 79253, from: "07/01/2022", to: "09/30/2022")
    set_variance_external_id(expected_amount: "-1021.35", entry: "JE2593", journal_id: 79257, from: "10/01/2022", to: "12/31/2022")
    set_variance_external_id(expected_amount: "-2582.44", entry: "JE2733", journal_id: 99296, from: "01/01/2023", to: "03/31/2023")
    set_variance_external_id(expected_amount: "-2771.75", entry: "JE2734", journal_id: 99297, from: "04/01/2023", to: "06/30/2023")
    set_variance_external_id(expected_amount: "-6728.13", entry: "JE3056", journal_id: 121586, from: "07/01/2023", to: "07/31/2023")
    set_variance_external_id(expected_amount: "-4265.10", entry: "JE3057", journal_id: 121587, from: "08/01/2023", to: "08/30/2023")
    set_variance_external_id(expected_amount: "-6974.65", entry: "JE3058", journal_id: 121588, from: "09/01/2023", to: "09/30/2023")
  end

  def down
    # Nothing to do
  end

  def set_variance_external_id(expected_amount:, entry:, journal_id:, from:, to:)
    puts "Migrating to journal entry #{entry} with expected amount: $#{expected_amount}, found amount: $#{fetch_existing_ppv_amount(from: from, to: to)}"

    fetch_purchases(from: from, to: to).each do |p|
      p.variance_external_id = journal_id
      p.save!
    end
  end

  def fetch_existing_ppv_amount(from:, to:)
    fetch_purchases(from: from, to: to).to_a.map(&:total_ppv).sum
  end

  def fetch_purchases(from:, to:)
    start_date = Date.strptime(from, "%m/%d/%Y").beginning_of_day
    end_date = Date.strptime(to, "%m/%d/%Y").end_of_day
    Purchase.where(purchase_date: (start_date..end_date)).includes(:purchase_details)
  end
end
