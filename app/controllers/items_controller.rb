class ItemsController < ApplicationController
  def index
    @items = Item.all
    @categories = Category.all

    if params[:category_id].present?
      @items = Item.where(category_id: params[:category_id])
      @category = Category.find(params[:category_id])
    end
  end

  def create
    params = item_params

    item = Item.new description: params[:description], category_id: params[:category_id]
    item.save

    redirect_to edit_item_path(item)
  end

  def edit
    @item = Item.find params[:id]
  end

  private

  def item_params
    params.require(:item).permit(:description, :category_id)
  end
end
