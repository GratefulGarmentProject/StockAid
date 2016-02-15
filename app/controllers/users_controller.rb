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
    user = User.find params[:id]

    user.update_attributes params.require("user").permit(:name, :email, :phone_number, :address)
    redirect_to root_path if user.save
  end
end
