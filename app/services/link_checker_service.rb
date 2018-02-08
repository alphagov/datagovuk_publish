class LinkCheckerService
  attr_reader :link

  def initialize(link)
    @link = link
  end

  def run
    begin
      check_link
    rescue RestClient::ExceptionWithResponse => error
      link.broken = true
      link.save(validate: false)
      create_broken_link_task(error)
    end
  end

  private

  def check_link
    link.attributes = {
      broken: !working?,
      format: file_format,
      size: file_size,
      last_check: Time.now
    }
    link.save(validate: false)
  end

  def create_broken_link_task(error)
    task = Task.find_or_initialize_by(related_object_id: dataset.uuid, category: "broken")
    task.attributes = {
      organisation_id: organisation.id,
      owning_organisation: organisation.name,
      required_permission_name: "",
      category: "broken",
      quantity: broken_link_count,
      related_object_id: dataset.uuid,
      description: error.message
    }
    task.save
  end

  def dataset
    @dataset ||= link.dataset
  end

  def organisation
    @organisation ||= Organisation.find_by(id: dataset.organisation_id)
  end

  def broken_link_count
    Link.where(dataset_id: dataset.id, broken: true).count
  end

  def response
    @response ||= RestClient::Request.execute(method: :head, url: link.url, timeout: 5)
  end

  def last_modified
    timestamp = response.headers[:last_modified]
    return Time.parse(timestamp) if !timestamp.nil?
  end

  def file_size
    response.headers[:content_length].to_i
  end

  def working?
    response.net_http_res.is_a?(Net::HTTPSuccess)
  end

  def file_format
    parse_content_type(response.headers[:content_type])
  end

  def parse_content_type(content)
    parts = content.split(';')
    mimetype = MIME::Types[parts[0]].first
    mimetype.preferred_extension.upcase()
  end
end
