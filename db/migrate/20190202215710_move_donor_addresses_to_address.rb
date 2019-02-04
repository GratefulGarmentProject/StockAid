class MoveDonorAddressesToAddress < ActiveRecord::Migration[5.0]
  def change
    logger = Logger.new(STDOUT)

    donors_with_addresses = Donor.where.not(address: nil)

    progress_tracker = PercentageDisplay.new(total: donors_with_addresses.count, logger: logger)

    logger.info("About to move #{progress_tracker.total} addresses.")

    donors_with_addresses.each do |donor|
      progress_tracker.increment_counter

      Address.create(address: donor.address)

      progress_tracker.update_percentage
    end

    remove_column :donors, :address
  end
end
