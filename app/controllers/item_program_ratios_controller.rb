class ItemProgramRatiosController < ApplicationController
  require_permission :can_view_item_program_ratios?
  require_permission :can_edit_item_program_ratios?, except: [:index]
  active_tab "inventory"

  def index
    @ratios = ItemProgramRatio.all.to_a
    @programs = Program.alphabetical.to_a
  end

  def new
    @programs = Program.alphabetical.to_a
  end

  def create
    current_user.create_item_program_ratio(params)
    redirect_to item_program_ratios_path, flash: { success: "Program ratios created!" }
  end

  def edit
    @ratio = ItemProgramRatio.find(params[:id])
    @programs = Program.alphabetical.to_a
  end

  def update
    current_user.update_item_program_ratio(params)
    redirect_to item_program_ratios_path, flash: { success: "Program ratios updated!" }
  end

  def destroy
    current_user.destroy_item_program_ratio(params)
    redirect_to item_program_ratios_path, flash: { success: "Program ratios deleted!" }
  end
end
