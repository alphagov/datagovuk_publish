class HomeController < ApplicationController

  def index
    home_path_for_user
  end

  def quality
    @scores = QualityScore.all.order(median: :desc, highest: :desc)
  end

  def dashboard
    @total_datasets = Dataset.count
    @total_datafiles = Link.count
    @total_publishers = Organisation.count
    @total_published_datasets = Dataset.published.count
    @total_draft_datasets = Dataset.draft.count
    @total_unpublished_datasets = Dataset.left_outer_joins(:datafiles).where(links: { id: nil } ).count # i.e. datasets with no datafiles
    @datafile_count_by_format = Datafile.group(:format).count.sort_by { |_k, value| value }.reverse
  end

  private

  def home_path_for_user
    if user_signed_in?
      redirect_to tasks_path
    end
  end
end
