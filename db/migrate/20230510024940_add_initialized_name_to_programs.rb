class AddInitializedNameToPrograms < ActiveRecord::Migration[5.2]
  def up
    add_column :programs, :initialized_name, :string, limit: 8
    add_index :programs, :initialized_name, unique: true

    Program.all.to_a.each do |program|
      program.initialized_name = program.name.gsub(/\b(\w)\w*?\b/, "\\1").gsub(/[\s\-]/, "")
      program.save!
    end

    change_column_null :programs, :initialized_name, false
  end

  def down
    remove_column :programs, :initialized_name
  end
end
