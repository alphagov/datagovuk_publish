class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    redirect_to tasks_path if user_signed_in?
  end

  def create
    authenticate_user!
    redirect_to tasks_path
  end
end
