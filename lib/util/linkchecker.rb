require 'rest-client'
require 'mime/types'
require 'util/organisation_checker'

module LinkChecker
  include OrganisationChecker

  def check_dataset(dataset)
    puts "Checking dataset #{dataset.title} (#{dataset.name})"
    dataset.links.each do |link|
      puts "Processing link"
      check_link(link)
    end
  end

  def check_link(link)
    puts "Checking link #{link.url}"
    LinkCheckerWorker.perform_async(link.id)
  end

  def save_result(link, response)
    working = response.code > 199 && response.code < 299
    file_format = parse_content_type(response.headers[:content_type])
    size = response.headers[:content_length].to_i
    last_modified = response.headers[:last_modified]

    link.update_attributes({
      last_modified: last_modified.blank? ? nil : Time.parse(last_modified),
      last_check: DateTime.now,
      broken: !working,
      format: file_format,
      size: size
    })
  end

  def parse_content_type(content)
    parts = content.split(';')
    mimetype = MIME::Types[parts[0]].first
    mimetype.preferred_extension.upcase()
  end

  def broken_link_count(dataset)
    dataset.joins(:links).merge(Link.where(broken:true)).count
  end

  def create_broken_link_task(link)
    dataset = link.dataset
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
