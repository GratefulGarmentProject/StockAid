class ItemsController < ApplicationController
  before_action :authenticate_user!
  def index
    @categories = Category.all
    if params[:category_id].present?
      @items = Item.where(category_id: params[:category_id])
      @category = Category.find(params[:category_id])
    end
  end
end
