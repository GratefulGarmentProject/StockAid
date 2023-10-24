class HelpLinksController < ApplicationController
  require_permission :can_edit_help_links?

  def index
    @links = HelpLink.for_editing
  end

  def create
    HelpLink.transaction do
      next_ordering = (HelpLink.maximum(:ordering) || 0) + 1
      HelpLink.create!(label: params[:label], url: params[:url], ordering: next_ordering, visible: false)
    end

    redirect_to help_links_path, flash: { success: "Help link created!" }
  end

  def destroy
    HelpLink.find(params[:id]).destroy!
    redirect_to help_links_path, flash: { success: "Help link deleted!" }
  end

  def toggle_visibility
    link = HelpLink.find(params[:id])
    link.visible = !link.visible
    link.save!
    redirect_to help_links_path
  end

  def move_up
    HelpLink.transaction do
      link = HelpLink.find(params[:id])
      link.move_up
    end

    redirect_to help_links_path
  end

  def move_down
    HelpLink.transaction do
      link = HelpLink.find(params[:id])
      link.move_down
    end

    redirect_to help_links_path
  end
end
