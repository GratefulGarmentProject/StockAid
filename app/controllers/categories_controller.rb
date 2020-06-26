class CategoriesController < ApplicationController
  require_permission :can_view_or_edit_categories?
  active_tab "inventory"

  def create
    new_category = Category.new(description: category_params[:description])
    if new_category.save
      flash[:success] = "Category '#{new_category.description}' created!"
    else
      flash[:error] = "#{new_category.errors.full_messages.join('. ')}.  Please try again."
    end
    redirect_to items_path
  end

  def new
    @categories = Category.all
    @category = Category.new

    render :edit
  end

  def edit
    @categories = Category.all
    @category = @categories.find(params[:id])
  end

  def update
    if category.update(category_params)
      redirect_to items_path(category_id: category.id), success: "Category '#{category.description}' updated!"
    else
      redirect_to :back, alert: category.errors.full_messages.to_sentence
    end
  end

  def destroy
    # Check if we are about to orphan some items
    move_orphaned_items_to_unknown_category if unscoped_items_for_category.any?

    category.destroy

    flash[:success] = "Category '#{category.description}' deleted!"
    redirect_to items_path
  end

  private

  def category
    @category ||= Category.find(params[:id])
  end

  def unscoped_items_for_category
    @unscoped_items_for_category ||= Item.unscoped.where(category_id: category.id)
  end

  def move_orphaned_items_to_unknown_category
    # Create an 'Unknown' category to store them
    unknown_category = Category.where(description: "Unknown").first_or_create

    unscoped_items_for_category.each { |item| item.update(category_id: unknown_category.id) }
  end

  def category_params
    params.require(:category).permit(:description)
  end
end
