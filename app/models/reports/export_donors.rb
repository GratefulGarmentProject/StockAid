require "csv"

module Reports
  class ExportDonors
    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << %w(ID Name Address Email)

        Donor.order("name ASC").each do |donor|
          csv << [donor.id, donor.name, donor.address, donor.email]
        end
      end
    end
  end
end
