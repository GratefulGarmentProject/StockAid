class AddExternalClassIdToPrograms < ActiveRecord::Migration[5.1]
  def up
    add_column :programs, :external_class_id, :integer

    Program.all.to_a.each do |program|
      case program.name
      when "Resource Closets"
        program.external_class_id = 1
      when "Human Trafficking/CSEC Resources"
        program.external_class_id = 2
      when "Pack-It-Forward"
        program.external_class_id = 3
      when "Operation Esteem"
        program.external_class_id = 5
      when "Dress for Dignity"
        program.external_class_id = 4
      when "Beautification Projects"
        program.external_class_id = 6
      else
        raise "Unknown program: #{program.name}"
      end

      program.save!
    end

    change_column_null :programs, :external_class_id, false
  end

  def down
    remove_column :programs, :external_class_id
  end
end
