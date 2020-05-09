class PopulateOrganizationAddresses < ActiveRecord::Migration[5.0][5.0]

  def change
    logger = Logger.new(STDOUT)

    progress_tracker = PercentageDisplay.new(total: Address.count, logger: logger)

    logger.info("About to update #{progress_tracker.total} records.")

    Address.all.each do |address|
      progress_tracker.increment_counter

      OrganizationAddress.create(address_id: address.id, organization_id: address.organization_id)

      progress_tracker.update_percentage
    end

    remove_reference :addresses, :organization, index: true
  end
end
