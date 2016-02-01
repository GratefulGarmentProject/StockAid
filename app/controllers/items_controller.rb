class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:edit, :update, :destroy]
  active_tab "inventory"

  def index
    @categories = Category.order(:description).all

    if params[:category_id].present?
      @items = Item.where(category_id: params[:category_id]).order(:description)
      @category = Category.find(params[:category_id])
    else
      @items = Item.includes(:category).order("categories.description, items.description").group_by(&:category)
    end
  end

  def edit
    @categories = Category.order(:description).all
  end

  def update
    @item.description = items_params[:description]
    @item.current_quantity = items_params[:current_quantity]
    if @item.save
      redirect_to items_path(category_id: @item.category.id)
    else
      redirect_to :back, alert: @item.errors.full_messages.to_sentence
    end
  end

  def create
    items = Item.create_items_for_sizes(params[:item][:sizes], items_params)
    if items.all?(&:save)
      flash[:success] = "'#{items.first.description}' created!"
    else
      flash[:error] = "Item failed to save. Please try again."
    end
    redirect_to :back
  end

  def destroy
    @item.destroy
    flash[:success] = "Item '#{@item.description}' deleted!"
    redirect_to items_path
  end

  private

  def items_params
    params.require(:item).permit(:description, :current_quantity, :category_id)
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
