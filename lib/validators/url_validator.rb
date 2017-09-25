require 'whois-parser'
require 'rest-client'
require 'logger'


class UrlValidator < ActiveModel::Validator
  def validate(record)
    urlPresent?(record) &&
        urlStartsWithProtocol?(record) &&
        validPath?(record)
  end

  def urlPresent?(record)
    error = 'Url was not present'

    !record.url or record.url.empty? ?
        createValidationError(record, error) :
        true
  end

  def urlStartsWithProtocol?(record)
    error = 'Url does not start with http or https'

    record.url !~ /^https?/ ?
        createValidationError(record, error) :
        true
  end

  def validPath?(record)
    begin
      RestClient.head record.url
    rescue 
      error = 'Url path is not valid'
      createValidationError(record, error)
    end
  end

  def createValidationError(record, error)
    Rails.logger.debug('Validation error: ' + error)
    record.errors[:url] << 'Please enter a valid url'
    false
  end
end
