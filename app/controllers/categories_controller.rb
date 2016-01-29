class CategoriesController < ApplicationController
  def create
    category = Category.new category_params

    if category.save
      flash[:success] = "Category '#{category.description}' created!"
    else
      flash[:error] = "#{category.errors.full_messages.join('. ')}.  Please try again."
    end

    redirect_to items_path
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
    unknown_category = Category.where(description: "Unknown").first_or_create

    items = category.items
    items.update_all(category_id: unknown_category.id)

    category.destroy

    redirect_to items_path, success: "Category '#{category.description}' deleted!"
  end

  private

  def category_params
    params.require(:category).permit(:description)
  end
end
