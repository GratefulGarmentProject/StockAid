require "csv"

module Reports
  class ExportOrganizations
    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << %w(ID Name County Phone\ Number Email)

        Organization.order("name ASC").each do |organization|
          csv << [
            organization.id,
            organization.name,
            organization.county,
            organization.phone_number,
            organization.email
          ]
        end
      end
    end
  end
end
