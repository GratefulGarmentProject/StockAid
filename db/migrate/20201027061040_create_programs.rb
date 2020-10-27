class CreatePrograms < ActiveRecord::Migration[5.1]
  def change
    create_table :programs do |t|
      t.string :name, null: false
      t.integer :external_id

      t.timestamps
    end

    create_table :organization_programs do |t|
      t.belongs_to :organization, foreign_key: true, null: false
      t.belongs_to :program, foreign_key: true, null: false

      t.timestamps
    end

    resource_closet = Program.create!(name: "Resource Closets", external_id: 6)
    Program.create!(name: "Human Trafficking/CSEC Resources", external_id: 12)
    Program.create!(name: "Pack-It-Forward", external_id: 5)
    Program.create!(name: "Youth Gift-Card/Incentive Program", external_id: 9)
    Program.create!(name: "Dress for Dignity", external_id: 2)
    Program.create!(name: "Beautification Projects", external_id: 1)

    Organization.all.each do |org|
      OrganizationProgram.create!(organization: org, program: resource_closet)
    end
  end
end
