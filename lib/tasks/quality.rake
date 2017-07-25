require 'quality/quality_score'

namespace :quality do

  desc "Quality score for named dataset"
  task :score,[:dataset] => :environment do |_, args|
    dataset = Dataset.find_by(name: args.dataset)
    q = QualityScore.new(dataset)
    p q.score
    p q.reasons
  end

end
