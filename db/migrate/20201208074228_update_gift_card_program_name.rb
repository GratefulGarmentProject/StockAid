class UpdateGiftCardProgramName < ActiveRecord::Migration[5.1]
  def up
    program = Program.find_by(name: "Youth Gift-Card/Incentive Program")

    if program
      program.name = "Operation Esteem"
      program.save!
    end
  end

  def down
    program = Program.find_by(name: "Operation Esteem")

    if program
      program.name = "Youth Gift-Card/Incentive Program"
      program.save!
    end
  end
end
