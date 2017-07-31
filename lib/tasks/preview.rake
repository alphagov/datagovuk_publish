require 'json'
require 'csv'
require 'preview/preview_generator'

namespace :preview do

  desc "Generate a preview for all CSV links"
  task :generate_all => :environment do |_, args|

    counter = 0
    total = Link.where(format: "CSV").count

    print "There are #{total} links to process\n"

    # Only generate previews for CSV right now, and only for ones
    # that do not have previews already.
    Link.where(format: "CSV").each do |link|
      next if link.preview
      print "Processing #{counter+=1}/#{total}\r"

      PreviewGenerator.new(link).generate
    end

    puts
  end

end
