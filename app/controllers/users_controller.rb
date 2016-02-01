class UsersController < ApplicationController
  active_tab "users"

  def index
    @users = User.order(:name)
  end

  def update
    user = User.find params[:id]

    user.update_attributes params.require("user").permit(:name, :email, :phone_number, :address)
    redirect_to root_path if user.save
  end
end
