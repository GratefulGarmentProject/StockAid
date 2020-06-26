class UserInvitationsController < ApplicationController
  active_tab "users"
  no_login only: %i[show update]
  require_permission :can_invite_user?, except: %i[show update]

  def new
    @user = User.new
    @user = User.find params[:user] if params[:user]
  end

  def create
    current_user.invite_user params
    redirect_to users_path
  rescue ActiveRecord::RecordInvalid => e
    @user = e.record.user
    @error_record = e.record
    render :new
  end

  def open
    @invites = UserInvitation.open_for_organization(current_user)

    render :index
  end

  def closed
    @invites = UserInvitation.closed_for_organization(current_user)

    render :index
  end

  def show
    @invite = UserInvitation.find_and_check(params)
  end

  def update
    UserInvitation.convert_to_user(params)
    redirect_to :root
  end
end
