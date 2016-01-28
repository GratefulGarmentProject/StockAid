class CategoriesController < ApplicationController
  def create
    category = Category.new category_params

    if category.save
      flash[:success] = "Category '#{category.description}' created!"
      redirect_to items_path
    end
  end

  private

  def category_params
    params.require(:category).permit(:description)
  end
end
