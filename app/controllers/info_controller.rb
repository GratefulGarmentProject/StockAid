class InfoController < ApplicationController
  def index
    render json: { version: Rails.application.config.version }
  end
end
