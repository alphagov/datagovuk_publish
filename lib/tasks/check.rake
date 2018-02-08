require 'util/overduechecker'

namespace :check do
  namespace :overdue  do
    desc "Check overdue datasets in an organisation"
    task :organisation, [:organisation] => :environment do |_, args|
      organisation = Organisation.find_by(name: args.organisation)

      puts "Checking overdue datasets for #{organisation.title}"

      organisation.datasets.find_each(batch_size: 10) do |dataset|
        OverdueChecker.check_dataset(dataset)
      end
    end

    desc "Check if a single dataset is overdue"
    task :dataset, [:dataset] => :environment do |_, args|
      dataset = Dataset.find_by(name: args.dataset)
      OverdueChecker.check_dataset(dataset)
    end
  end

  namespace :links  do
    desc "Check for broken links"
    task all: :environment do
      Link.find_each(batch_size: 10) do |link|
        LinkCheckerWorker.perform_async(link.id)
      end
    end

    desc "Check for broken links in a single dataset"
    task :dataset, [:dataset] => :environment do |_, args|
      dataset = Dataset.find_by(name: args.dataset)

      puts "Checking dataset #{dataset.title} (#{dataset.name})"

      dataset.links.each do |link|
        puts "Processing datafile"
        LinkCheckerWorker.perform_async(link.id)
      end
    end

    desc "Check for broken links in each dataset of an organisation"
    task :organisation, [:organisation] => :environment do |_, args|
      organisation = Organisation.find_by(name: args.organisation)
      datasets = Dataset.includes(organisation_id: organisation.id)

      puts "Checking datasets for #{organisation.title}"

      datasets.find_each(batch_size: 10) do |dataset|
        dataset.links.each do |link|
          puts "Processing datafile"
          LinkCheckerWorker.perform_async(link.id)
        end
      end
    end
  end
end
