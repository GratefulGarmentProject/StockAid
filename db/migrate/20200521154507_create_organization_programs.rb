class CreateOrganizationPrograms < ActiveRecord::Migration[5.0]
  def change
    create_table :organization_programs do |t|
      t.belongs_to :organization, foreign_key: true
      t.belongs_to :program, foreign_key: true
      t.boolean :default, null: false, default: false

      t.timestamps
    end
  end
end
