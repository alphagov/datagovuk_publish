require 'util/linkchecker'

namespace :linkcheck do
  desc "Check links for the specified organisation"

  task :organisation, [:organisation] => :environment do |_, args|
    organisation = Organisation.find_by(name: args.organisation)
    LinkChecker.check_organisation(organisation)
  end

  task :dataset, [:dataset] => :environment do |_, args|
    dataset = Dataset.find_by(name: args.dataset)
    LinkChecker.check_dataset(dataset)
  end

end
