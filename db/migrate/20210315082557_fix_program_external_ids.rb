class FixProgramExternalIds < ActiveRecord::Migration[5.1]
  def change
    return if Rails.env.test?

    program = Program.find_by_name("Human Trafficking/CSEC Resources")
    program.external_id = 3
    program.save!
  end
end
