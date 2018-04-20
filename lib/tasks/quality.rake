require 'quality/quality_score_calculator'

namespace :quality do
  desc "Quality score for named dataset"
  task :score, [:dataset] => :environment do |_, args|
    dataset = Dataset.find_by(name: args.dataset)
    QualityScoreCalculator.new(dataset)
  end

  desc "Calculate scores for an organisation, argument is an organisation short-name e.g. cabinet-office"
  task :calculate, [:organisation] => :environment do |_, args|
    organisation = Organisation.find_by(name: args.organisation)
    calculate_organisation_score(organisation)
  end

  desc "Calculate scores for all organisations"
  task :calculate_all, [] => :environment do |_, _args|
    count = 1
    total = Organisation.all.count

    Organisation.all.each do |organisation|
      print "Processing #{count}/#{total}\r"

      calculate_organisation_score(organisation)
      count += 1
    end
  end
end

def calculate_organisation_score(organisation)
  current_scores = []

  datasets = organisation.datasets.preload(:links).preload(:docs).all
  if datasets.size.zero?
    print "\nSkipping empty organisation"
    return
  end

  datasets.each do |dataset|
    q = QualityScoreCalculator.new(dataset)
    current_scores << q.score
  end

  average = current_scores.inject { |sum, el| sum + el }.to_f / current_scores.size
  average = average.round(2)

  sorted = current_scores.sort
  len = sorted.length
  median = 0 if len.zero?
  median = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0 if len.positive?

  current = QualityScore.find_by(organisation_id: organisation.id)
  current = QualityScore.new if current.blank?
  current.highest = current_scores.max
  current.lowest  = current_scores.min
  current.average = average
  current.median  = median
  current.organisation_id = organisation.id
  current.organisation_name = organisation.name
  current.organisation_title = organisation.title
  current.total = organisation.datasets.count
  current.save!
end
