require "csv"

class UpdateOrganogramFilenames
  def initialize
    @old_urls = []
    @new_urls = []
  end

  def call
    csv_file = "./lib/tasks/old_new_urls.csv"

    parse_csv(csv_file)
    msg = replace_urls
    puts msg
  end

  def parse_csv(csv_file)
    puts "Parsing CSV '#{csv_file}'"
    CSV.foreach(csv_file) do |row|
      @old_urls << row.first
      @new_urls << row.last.strip
    end
  end

  def replace_urls
    puts "Searching for urls containing '-posts-'..."

    if @old_urls.empty?
      "No urls to process"
    else
      Link.where("url LIKE 'https://s3-eu-west-1.amazonaws.com%'").each do |link|
        next unless link.url.include? "-posts-"

        index = @old_urls.index(link.url)
        if !index.nil?
          puts "From dataset: " + link.dataset.name
          puts "Replace url '" + link.url + "' with '" + @new_urls[index] + "'"
          link.url = @new_urls[index]
          link.save(validate: false)

          if Link.where(url: @new_urls[index]).empty?
            puts "Url replacement failed"
          else
            puts "Url successfully replaced"
          end
        else
          puts "WARNING: " + link.url + " not found"
        end
        puts "==============="
      end
      "Update complete"
    end
  end
end
