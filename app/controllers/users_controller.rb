class UsersController < ApplicationController
  active_tab "users"
  require_permission :can_update_user?, only: [:index]
  require_permission :can_delete_user?, only: [:destroy, :deleted]

  def index
    @users = User.includes(:organizations).order(:name).updateable_by(current_user).not_deleted
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
      redirect_to users_path
    end
  end

  def destroy
    current_user.destroy_user(params)
    redirect_to users_path
  end

  def deleted
    @users = User.includes(:organizations).order(:name).updateable_by(current_user).deleted
  end
end
