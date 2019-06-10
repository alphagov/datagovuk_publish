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
    File.open(csv_file).readlines.each do |line|
      urls = line.split(', ')
      urls.last.delete! "\n"

      @old_urls << urls.first
      @new_urls << urls.last
    end
  end

  def replace_urls
    puts "Searching for urls containing '-posts-'..."

    if @old_urls.empty?
      "No urls to process"
    else
      Link.all.each do |link|
        if link.url.include? "-posts-"
          index = @old_urls.index(link.url)
          if index != nil
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
      end
      "Update complete"
    end
  end
end
