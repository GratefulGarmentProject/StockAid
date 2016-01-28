class CategoriesController < ApplicationController
  def create
    sizes = category_params[:sizes].split(',').map(&:strip)
    description = category_params[:description]
    category = Category.new({sizes: sizes, description: description})
    if category.save
      flash[:success] = "Category '#{category.description}' created!"
    else
      flash[:error] = "#{category.errors.full_messages.join('. ')}.  Please try again."
    end

    redirect_to items_path
  end

  private

  def category_params
    params.require(:category).permit(:description, :sizes)
  end
end
