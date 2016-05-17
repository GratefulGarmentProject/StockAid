class UserInvitationsController < ApplicationController
  active_tab "users"
  no_login only: [:show, :update]
  require_permission :can_invite_user?, except: [:show, :update]

  def new
    @user = User.new
    @user = User.find params[:user] if params[:user]
  end

  def create
    if UserInvitation.valid? params
      current_user.invite_user params
      redirect_to users_path
    else
      alert = "User invitation is invalid. #{params[:user][:email]} already exists at #{Organization.find(params[:user][:organization_id]).name} with this role."
      redirect_to users_path, alert: alert
    end
  end

  def index
    @invites = UserInvitation.for_organization(current_user.organizations_with_permission_enabled(:can_invite_user_at?))
  end

  def show
    @invite = UserInvitation.find_and_check(params)
  end

  def update
    UserInvitation.convert_to_user(params)
    redirect_to :root
  end
end
