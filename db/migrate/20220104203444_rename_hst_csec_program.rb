class RenameHstCsecProgram < ActiveRecord::Migration[5.1]
  def up
    program = Program.find_by(name: "Human Trafficking/CSEC Resources")

    if program
      program.name = "Beyond the Closet"
      program.save!
    end
  end

  def down
    program = Program.find_by(name: "Beyond the Closet")

    if program
      program.name = "Human Trafficking/CSEC Resources"
      program.save!
    end
  end
end
