require 'whois-parser'
require 'rest-client'
require 'logger'


class UrlValidator < ActiveModel::Validator
  def validate(record)
    url_present?(record) &&
      url_starts_with_protocol?(record) &&
      valid_path?(record)
  end

  def url_present?(record)
    error = 'Url was not present'

    record.url.blank? ? create_validation_error(record, error) : true
  end

  def url_starts_with_protocol?(record)
    error = 'Url does not start with http or https'

    if record.url !~ /^https?/
      create_validation_error(record, error)
    else
      true
    end
  end

  def valid_path?(record)
    error = nil

    begin
      RestClient.head record.url
      return true
    rescue RestClient::ExceptionWithResponse
      error = 'Url path is not valid'
    rescue SocketError
      error = 'There was a problem connecting to the server'
    rescue Errno::ECONNREFUSED
      error = 'The server refused a connection attempt'
    end

    create_validation_error(record, error) if error.present?
    false
  end

  def create_validation_error(record, error)
    Rails.logger.debug('Validation error: ' + error)
    record.errors[:url] << 'Please enter a valid url'
    false
  end
end
