class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:edit, :edit_stock, :update, :destroy]
  active_tab "inventory"

  def index
    @categories = Category.all

    if params[:category_id].present?
      @items = Item.where(category_id: params[:category_id]).order(:description)
      @category = Category.find(params[:category_id])
    else
      @items = Item.includes(:category).order("categories.description, items.description").group_by(&:category)
    end
  end

  def new
    @categories = Category.all
    @item = Item.new(category_id: params[:category_id])

    render :edit
  end

  def edit
    @categories = Category.all
  end

  def edit_stock
    @categories = Category.all
  end

  def update
    @item.assign_attributes item_params
    @item.mark_event item_event_params

    if @item.save
      flash[:success] = "'#{@item.description}' updated"
      redirect_to items_path(category_id: @item.category.id)
    else
      redirect_to :back, alert: @item.errors.full_messages.to_sentence
    end
  end

  def create
    items = Item.create_items_for_sizes(params[:item][:sizes], item_params)
    if items.all?(&:save)
      flash[:success] = "'#{items.first.description}' created!"
    else
      flash[:error] = "Item failed to save. Please try again."
    end
    redirect_to items_path(category_id: items.first.category_id)
  end

  def destroy
    if @item.destroy
      flash[:success] = "Item '#{@item.description}' deleted!"
    else
      flash[:error] = "'#{@item.description}' could not be deleted."
    end
    redirect_to items_path(category_id: @item.category_id)
  end

  private

  def item_params
    params.require(:item).permit(:description, :current_quantity, :category_id)
  end

  def item_event_params
    params.require(:item).permit(:edit_amount, :edit_method, :edit_reason, :edit_source)
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
