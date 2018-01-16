require 'rest-client'
require 'mime/types'
require 'util/organisation_checker'

module LinkChecker
  include OrganisationChecker

  # Checks all of the links within the specified dataset and updates each
  # link as necessary with success, size, mimetype, last-modified etc.
  def check_dataset(dataset)
    puts "Checking dataset #{dataset.title} (#{dataset.name})"
    datafiles = Link.includes(:dataset_id => dataset.id)
    datafiles.each do |datafile|
      puts "Processing datafile"
      check_link(datafile)
    end
  end

  # Given a datafile, checks if the link is broken or not, and if not
  # record some extra metadata about it before saving.
  def check_link(datafile)
    puts "Checking link #{datafile.url}"

    begin
      response = RestClient.head datafile.url
      save_result(datafile, response)
    rescue RestClient::ExceptionWithResponse
      datafile.broken = true
      datafile.save()
      create_broken_link_task(datafile)
    end
  end

  # When provided with a datafile and a HTTP response then this function
  # will update some of the datafile metadata, such as last-modified, size,
  # format etc based on what is available.
  # The changed datafile is then saved.
  def save_result(datafile, response)
    working = response.code > 199 && response.code < 299
    file_format = parse_content_type(response.headers[:content_type])

    last_modified = response.headers[:last_modified]
    if last_modified != nil
      last_modified = Time.parse last_modified
      datafile.last_modified = last_modified
    end

    datafile.broken = !working
    datafile.format = file_format
    datafile.size = response.headers[:content_length].to_i
    datafile.last_check = DateTime.now
    datafile.save()
  end

  # Splits the content type (removing the charset if necessary) and
  # then determins the preferred extension to use as a format.
  def parse_content_type(content)
    parts = content.split(';')
    mimetype = MIME::Types[parts[0]].first
    mimetype.preferred_extension.upcase()
  end

  def broken_link_count
    dataset.joins(:links).merge(Link.where(broken:true)).count
  end

  # Creates a new task for dataset with broken datafile links
  def create_broken_link_task(datafile)
    dataset = datafile.dataset
    org = Organisation.find_by(id: dataset.organisation_id)

    if Task.where(related_object_id: dataset.uuid, category: "broken").exists?
      t = Task.new
    else
      t = Task.where(related_object_id: dataset.uuid, category: "broken")
    end

    t.organisation_id = org.id
    t.owning_organisation = org.name
    t.required_permission_name = ""
    t.category = "broken"
    t.quantity = broken_link_count(dataset)
    t.related_object_id = dataset.uuid
    t.created_at = t.updated_at = DateTime.now
    t.description = "'#{dataset.title}' contains broken links"
    t.save()

  end

  module_function :check_organisation, :check_dataset, :check_link,
    :save_result, :parse_content_type, :create_broken_link_task, :broken_link_count
end
