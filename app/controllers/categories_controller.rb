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

  private

  def category_params
    params.require(:category).permit(:description)
  end
end
