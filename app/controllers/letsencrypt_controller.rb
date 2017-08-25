class LetsencryptController < ApplicationController
  skip_before_action :authenticate_user!

  def authenticate
    render text: "#{params[:id]}.UkBqYez_hoHrzth06uZUC07h5I6syXbEvb_XqUF8eYs"
  end
end
