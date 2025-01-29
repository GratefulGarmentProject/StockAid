class AddCountyTable < ActiveRecord::Migration[6.1]
  def change
    create_table :counties do |t|
      t.string :name, null: false
      t.integer :external_id
      t.index :name, unique: true
    end

    add_reference :organizations, :organization_county, index: true, null: true
    add_reference :donors, :county, index: true, null: true
    add_reference :donations, :county, index: true, null: true

    reversible do |dir|
      dir.up do
        existing_counties = Organization.unscoped.distinct.where.not(county: nil).pluck(:county).sort
        counties_by_name = {}

        existing_counties.each do |county|
          new_county = County.create!(name: county)
          counties_by_name[county] = new_county
        end

        Organization.unscoped.find_each do |org|
          next if org.county.blank?

          org.organization_county = counties_by_name[org.county]
          org.save!
        end
      end

      dir.down do
        # Nothing to do
      end
    end
  end
end
