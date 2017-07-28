class HomeController < ApplicationController
  before_action :home_path_for_user

  def index
  end

  # FIX: Temporary controller, remove me when no longer required
  def org_quality
    require 'quality/quality_score'
    scores = []

    @organisation = Organisation.preload(:datasets).find_by(name: params.require(:id))
    datasets = @organisation.datasets.preload(:links).preload(:docs).all
    datasets.each do |dataset|
      q = QualityScore.new(dataset)
      scores << q.score
    end

    @highest = scores.max
    @lowest = scores.min
    @average = scores.inject{ |sum, el| sum + el }.to_f / scores.size
    @average = @average.round(2)

    sorted = scores.sort
    len = sorted.length
    @median = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0

    @total = datasets.count
  end

private
  def home_path_for_user
    if user_signed_in?
      redirect_to tasks_path
    end
  end

end
