require 'util/overduechecker'

namespace :overduecheck do
  desc "Check overdue datasets for the specified organisation"

  task :organisation, [:organisation] => :environment do |_, args|
    organisation = Organisation.find_by(name: args.organisation)
    OverdueChecker.check_organisation(organisation)
  end

  task :dataset, [:dataset] => :environment do |_, args|
    dataset = Dataset.find_by(name: args.dataset)
    OverdueChecker.check_dataset(dataset)
  end

end
