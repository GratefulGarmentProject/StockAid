class ItemsController < ApplicationController
  def index
    @categories = Category.all
    if params[:category_id].present?
      @items = Item.where(category_id: params[:category_id])
      @category = Category.find(params[:category_id])
    end
  end
end
