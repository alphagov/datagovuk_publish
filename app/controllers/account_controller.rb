class AccountController < ApplicationController
  protect_from_forgery prepend: :true
  before_action :authenticate_user!

  def show
    @user = User.find params[:id]
  end
end
