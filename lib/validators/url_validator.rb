require 'addressable/uri'
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
    uri = Addressable::URI.parse(record.url)
    return false if uri.blank?

    error = 'Url does not start with http, https, or ftp'

    if %w(http https ftp).exclude? uri.scheme
      create_validation_error(record, error)
    else
      true
    end
  end

  def encoded?(original_url)
    decoded = Addressable::URI.unescape(original_url)
    decoded != original_url
  end

  def encoded_url(url)
    return Addressable::URI.escape(url) if encoded?(url)
    url
  end

  def valid_path?(record)
    begin
      RestClient.head encoded_url(record.url)
    rescue RestClient::ExceptionWithResponse
      error = 'Url path is not valid'
      create_validation_error(record, error)
    end
  end

  def create_validation_error(record, error)
    Rails.logger.debug('Validation error: ' + error)
    record.errors[:url] << 'Please enter a valid url'
    false
  end
end
