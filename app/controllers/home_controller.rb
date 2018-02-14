class HomeController < ApplicationController

  def index
    home_path_for_user
  end

  def quality
    @scores = QualityScore.all.order(median: :desc, highest: :desc)
  end

  def dashboard
    @datasets_count = Dataset.count
    @datafiles_count = Link.count
    @publishers_count = Organisation.count
    @datasets_published_with_datafiles_count = Dataset.with_datafiles.distinct.count
    @datasets_published_with_no_datafiles_count = Dataset.with_no_datafiles.count
    @datafiles_count_by_format = Datafile.group(:format).count.sort_by { |_k, value| value }.reverse
    @broken_links_count = Link.broken.count
  end

  private

  def home_path_for_user
    if user_signed_in?
      redirect_to tasks_path
    end
  end
end
