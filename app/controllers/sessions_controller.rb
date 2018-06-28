class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    redirect_to manage_path if user_signed_in?
  end

  def create
    authenticate_user!
    redirect_to manage_path
  end
end
