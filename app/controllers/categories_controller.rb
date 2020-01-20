class CategoriesController < ApplicationController
  require_permission :can_view_or_edit_categories?
  active_tab "inventory"

  def create
    category = Category.new(description: category_params[:description])
    if category.save
      flash[:success] = "Category '#{category.description}' created!"
    else
      flash[:error] = "#{category.errors.full_messages.join('. ')}.  Please try again."
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
    category = Category.find(params[:id])

    category.assign_attributes category_params

    if category.save
      redirect_to items_path(category_id: category.id), success: "Category '#{category.description}' updated!"
    else
      redirect_to :back, alert: category.errors.full_messages.to_sentence
    end
  end

  def destroy
    category = Category.find(params[:id])
    items = Items.unscoped.where(category_id: category.id)
    # Check if we are about to orphan some items
    if items.any?
      # Create an 'Unknown' category to store them
      unknown_category = Category.where(description: "Unknown").first_or_create
      items.update_all(category_id: unknown_category.id)
    end

    category.destroy

    flash[:success] = "Category '#{category.description}' deleted!"
    redirect_to items_path
  end

  private

  def category_params
    params.require(:category).permit(:description)
  end
end
