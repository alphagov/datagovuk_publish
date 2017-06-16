require 'util/linkchecker'
require 'util/overduechecker'

namespace :check do

  namespace :overdue  do

    desc "Check overdue datasets in an organisation"
    task :organisation, [:organisation] => :environment do |_, args|
      organisation = Organisation.find_by(name: args.organisation)
      OverdueChecker.check_organisation(organisation)
    end

    desc "Check if a single dataset is overdue"
    task :dataset, [:dataset] => :environment do |_, args|
      dataset = Dataset.find_by(name: args.dataset)
      OverdueChecker.check_dataset(dataset)
    end

  end

  namespace :links  do

    desc "Check if a single dataset is overdue"
    task :dataset, [:dataset] => :environment do |_, args|
      dataset = Dataset.find_by(name: args.dataset)
      LinkChecker.check_dataset(dataset)
    end

    desc "Check for broken links in each dataset of an organisation"
    task :organisation, [:organisation] => :environment do |_, args|
      organisation = Organisation.find_by(name: args.organisation)
      LinkChecker.check_organisation(organisation)
    end

  end

end

