class AddProgramToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_reference :organizations, :program, foreign_key: true
  end
end
