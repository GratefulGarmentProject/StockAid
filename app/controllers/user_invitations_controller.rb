class UserInvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  before_action(except: :show) { require_permission :can_invite_user? }

  def new
  end

  def create
    current_user.invite_user params
    redirect_to :root
  end

  def show
  end
end
