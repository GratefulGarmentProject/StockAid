class OrganizationProgram < ApplicationRecord
  belongs_to :organization
  belongs_to :program

  def self.default_program
    find_by(default: true)&.program
  end

  def self.default_program=(program)
    # make sure this program is within the organization program association
    this_organization_program = find_by(program_id: program.id)
    raise ActiveRecord::RecordNotFound unless this_organization_program.present?

    # check if program is the current default for the organization so we can go home early
    current_default = find_by(default: true)
    return if current_default == this_organization_program

    current_default.update_column(:default, false) if current_default.present?
    this_organization_program.update_column(:default, true)
    default_program
  end
end
