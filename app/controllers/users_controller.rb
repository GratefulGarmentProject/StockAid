class UsersController < ApplicationController
  def update
    user = User.find params[:id]

    user.update_attributes params.require("user").permit(:name, :email)
    redirect_to root_path if user.save
  end
end
