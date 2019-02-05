class MoveDonorAddressesToAddress < ActiveRecord::Migration[5.0]
  def up
    logger = Logger.new(STDOUT)

    donors_with_addresses = Donor.where.not(address: nil)

    progress_tracker = PercentageDisplay.new(total: donors_with_addresses.count, logger: logger)

    logger.info("About to move #{progress_tracker.total} addresses.")

    donors_with_addresses.each do |donor|
      progress_tracker.increment_counter

      address = Address.create(address: donor.address)
      DonorAddress.create(donor: donor, address: address)

      progress_tracker.update_percentage
    end

    remove_column :donors, :address
  end

  def down
    add_column :donors, :address

    logger = Logger.new(STDOUT)

    donors_with_addresses = Donor.joins(:donor_addresses)

    progress_tracker = PercentageDisplay.new(total: donors_with_addresses.count, logger: logger)

    logger.info("About to move #{progress_tracker.total} addresses back to Donor from Addresses.")

    donors_with_addresses.each do |donor|
      progress_tracker.increment_counter

      donor.address = donor.primary_address
      donor.save!

      donor.donor_addresses.destroy_all
      donor.addresses.destroy_all

      progress_tracker.update_percentage
    end
  end
end
