class UsersController < ApplicationController
  active_tab "users"
  require_permission :can_update_user?, only: [:index]

  def index
    @users = User.order(:name).updateable_by(current_user)
  end

  def edit
    @user = User.find(params[:id])
    raise PermissionError unless current_user.can_update_user?(@user)
  end

  def update
    current_user.update_user params

    if params[:id].to_i == current_user.id
      redirect_to root_path
    else
      redirect_to action: :index
    end
  end
end
