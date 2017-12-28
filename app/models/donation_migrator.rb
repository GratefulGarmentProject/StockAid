class DonationMigrator
  def initialize(donations)
    @donations = donations.map { |_, versions| DonationToMigrate.new(versions) }.sort_by(&:edit_source)
  end

  def self.all
    new(scope.all.group_by { |x| "#{x.edit_source} #{x.created_at.to_date}" })
  end

  def self.any?
    scope.count > 0
  end

  def self.scope
    Item.paper_trail_version_class.where(edit_reason: "donation").where("edit_source NOT SIMILAR TO ?", "Donation #\\d+")
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
