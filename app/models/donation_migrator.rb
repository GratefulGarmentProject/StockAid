class DonationMigrator
  def initialize(donations: nil, user: nil, params: nil)
    @donations = donations
    @user = user
    @params = params
  end

  def self.all
    donations = scope.all.group_by { |x| "#{x.edit_source} #{x.created_at.to_date}" }
    donations = donations.map { |_, versions| DonationToMigrate.new(versions) }.sort_by(&:edit_source)
    new(donations: donations)
  end

  def self.migrate(user, params)
    Donation.transaction do
      raise PermissionError unless user.can_create_donations?
      new(user: user, params: params).migrate
    end
  end

  def self.any?
    scope.count > 0
  end

  def self.scope
    Item.paper_trail_version_class
        .where(edit_reason: "donation")
        .where("edit_source NOT SIMILAR TO ?", "Donation #\\d+")
  end

  def migrate # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    donor = Donor.create_or_find_donor(@params)
    donations_params = @params.require(:donations)
    version_ids_params = donations_params.require(:version_ids)
    notes_params = donations_params.require(:notes)
    date_params = donations_params.require(:date)

    version_ids_params.each_with_index do |version_ids, i| # rubocop:disable Metrics/BlockLength
      version_ids = version_ids.split(",").map(&:to_i)
      notes = notes_params[i]
      date = date_params[i]
      versions = DonationMigrator.scope.includes(:item).find(version_ids)

      donation = Donation.create!(
        donor: donor,
        user: @user,
        notes: notes,
        donation_date: date,
        created_at: versions.first.created_at,
        updated_at: versions.first.created_at
      )

      versions.each do |version|
        item = version.reify

        quantity =
          case version.edit_method
          when "new_total"
            version.edit_amount
          when "add"
            version.edit_amount
          when "subtract"
            -version.edit_amount
          else
            raise "Invalid edit_method: #{version.edit_method}"
          end

        details = DonationDetail.new(
          donation: donation,
          item: item,
          quantity: quantity,
          value: item.value,
          created_at: version.created_at,
          updated_at: version.created_at
        )

        details.for_migration = true
        details.save!
      end

      DonationMigrator.scope.where(id: version_ids).find_each do |version|
        version.update(edit_source: "Donation ##{donation.id}")
      end
    end
  end

  def each(&block)
    @donations.each(&block)
  end

  class DonationToMigrate
    def initialize(versions)
      @versions = versions
    end

    def edit_source
      @versions.first.edit_source.presence || "Unknown Donor"
    end

    def created_at
      @versions.first.created_at
    end

    def checkbox_value
      @versions.map(&:id).join(",")
    end
  end
end
