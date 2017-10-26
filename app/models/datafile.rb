require 'securerandom'
require 'validators/url_validator'

class Datafile < ApplicationRecord
  belongs_to :dataset

  validates :name, presence: true
  validates_with UrlValidator

  before_save :set_uuid
  before_save :set_format

  FILE_TYPES = ['html', 'csv', 'pdf', 'aspx', 'odt', 'xml', 'wms', 'xls','wfs','json', 'rdf', 'jpeg']

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

  def set_format
    if self.format.blank?
      self.format = get_format
    end
  end

  private

  def get_format
    begin
      response = RestClient.head self.url
    rescue
      RestClient::ExceptionWithResponse
    end
    file_format = response.headers[:content_type].downcase
    FILE_TYPES.map{ |type| file_format.include?(type)}
    FILE_TYPES.fetch(0,"")
  end

end
