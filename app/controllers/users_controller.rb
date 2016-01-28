class UsersController < ApplicationController

  def update
    user = User.find params[:id]

    user.update_attributes params.require("user").permit(:name, :email)
    if user.save
      redirect_to root_path
    end
  end
end
