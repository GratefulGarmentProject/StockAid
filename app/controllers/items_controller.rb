class ItemsController < ApplicationController
  require_permission :can_view_and_edit_items?, except: [:index]
  require_permission :can_view_items?, only: [:index]
  require_permission :can_bulk_price_items?, only: [:bulk_pricing, :update_bulk_pricing]
  before_action :authenticate_user!
  active_tab "inventory"

  def index
    @categories = Category.all
    @items = Item.includes(:category).with_requested_quantity.for_category(params[:category_id])
    @category = Category.find(params[:category_id]) if params[:category_id].present?
  end

  def new
    @categories = Category.all
    @item = Item.new(category_id: params[:category_id])
    @category = @item.category

    render :edit
  end

  def edit
    @categories = Category.all
    @item = Item.find_any(params[:id])
  end

  def edit_stock
    @categories = Category.all
    @item = Item.find_any(params[:id])
  end

  def update # rubocop:disable Metrics/AbcSize
    @item = Item.find(params[:id])

    item_params = params.require(:item)
                        .permit(:description, :current_quantity, :category_id, :value, :item_program_ratio_id)
    item_params[:value]&.delete!(",")
    item_event_params = params.require(:item).permit(:edit_amount, :edit_method, :edit_reason, :edit_source)

    @item.assign_attributes item_params
    @item.mark_event item_event_params
    @item.update_bins!(params)

    if @item.save
      flash[:success] = "'#{@item.description}' updated"
      redirect_to items_path(category_id: @item.category.id)
    else
      redirect_to :back, alert: @item.errors.full_messages.to_sentence
    end
  end

  def create
    item_params = params.require(:item)
                        .permit(:description, :current_quantity, :category_id, :value, :item_program_ratio_id)
    item = Item.new(item_params)
    if item.save
      flash[:success] = "'#{item.description}' created!"
    else
      flash[:error] = "'#{item.description}' failed to save. Please try again."
    end
    redirect_to items_path(category_id: item.category_id)
  end

  def destroy
    @item = Item.find(params[:id])
    if @item.soft_delete
      flash[:success] = "Item '#{@item.description}' deleted!"
    else
      flash[:error] = "'#{@item.description}' was unable to be deleted."
    end
    redirect_to items_path(category_id: @item.category_id)
  end

  def restore
    @item = Item.find_deleted(params[:id])
    @item.restore

    redirect_to edit_item_path(@item)
  end

  def deleted
    @categories = Category.all
    @items = Item.deleted
    @category = "Deleted Items"
  end

  def bulk_pricing
    @items = Item.includes(:category)
  end

  def update_bulk_pricing
    redirect_to bulk_pricing_items_path
  end
end
