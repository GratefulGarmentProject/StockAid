class LetsencryptController < ApplicationController
  skip_before_action :authenticate_user!

  def authenticate
    render text: "#{params[:id]}.xQk3L_ZooytfqxYnB78MxA3nMkWHp7bd6j8jAExcZMs"
  end
end
