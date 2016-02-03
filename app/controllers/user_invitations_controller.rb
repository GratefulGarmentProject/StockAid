class UserInvitationsController < ApplicationController
  no_login only: [:show, :update]
  require_permission :can_invite_user?, except: [:show, :update]

  def new
  end

  def create
    current_user.invite_user params
    redirect_to :root
  end

  def show
    @invite = UserInvitation.find_and_check(params)
  end

  def update
    UserInvitation.convert_to_user(params)
    redirect_to :root
  end
end
