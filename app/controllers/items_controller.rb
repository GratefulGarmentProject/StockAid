class ItemsController < ApplicationController
  before_action :authenticate_user!
  def index
    @categories = Category.all
    if params[:category_id].present?
      @items = Item.where(category_id: params[:category_id])
      @category = Category.find(params[:category_id])
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    @item.description = items_params[:description]
    @item.current_quantity = items_params[:current_quantity]
    if @item.save
      respond_to do |format|
        format.html { redirect_to items_path(category_id: @item.category.id) }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_item_path(@item.id) }
      end
    end
  end

  private

  def items_params
    params.require(:item).permit(:description, :current_quantity )
  end
end
