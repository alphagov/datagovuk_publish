class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  def dashboard
    @datasets_count = Dataset.count
    @datafiles_count = Link.count
    @publishers_count = Organisation.count
    @datasets_published_with_datafiles_count = Dataset.with_datafiles.distinct.count
    @datasets_published_with_no_datafiles_count = Dataset.with_no_datafiles.count
    @datafiles_count_by_format = Datafile.group(:format).count.sort_by { |_k, value| value }.reverse
    @broken_links_count = Link.broken.count
  end
end
