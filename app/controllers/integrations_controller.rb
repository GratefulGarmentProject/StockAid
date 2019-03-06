class IntegrationsController < ApplicationController
  active_tab "integrations"

  require_permission :can_view_integrations?

  def show
    @total_inventory_value = Category.includes(:items).to_a.sum(&:value)
  end
end
