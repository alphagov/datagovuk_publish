class HomeController < ApplicationController

  def index
    home_path_for_user
  end

  # FIX: Temporary controller, remove me when no longer required
  def quality
    @scores = QualityScore.all.order(median: :desc, highest: :desc)
  end

  private

  def home_path_for_user
    if user_signed_in?
      redirect_to tasks_path
    end
  end

end
