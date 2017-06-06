class HomeController < ApplicationController
  before_action :home_path_for_user

  def index
  end

private
  def home_path_for_user
    if publishing_user_signed_in?
      redirect_to tasks_path
    end
  end

end
