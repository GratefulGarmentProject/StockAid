class UsersController < ApplicationController
  active_tab "users"
  require_permission :can_update_user?, only: [:index]
  require_permission :can_delete_user?, only: %i[destroy deleted]
  require_permission :can_force_password_reset?, only: [:reset_password]
  require_permission :can_view_reports?, only: [:export]

  def index
    @users = User.includes(:organizations).order(:name).updateable_by(current_user).not_deleted
  end

  def export
    send_csv Reports::UserExport.new(current_user, session),
             filename: "users-#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
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
  rescue ActiveRecord::RecordInvalid => e
    @user = e.record
    render :edit
  end

  def destroy
    current_user.destroy_user(params)
    redirect_to users_path
  end

  def deleted
    # TODO: Should this trigger an email?
    @users = User.includes(:organizations).order(:name).updateable_by(current_user).deleted
  end

  def reset_password
    user = current_user.reset_password_for_user(params)
    redirect_to users_path, flash: { success: "Sent password reset to #{user.name}" }
  end
end
