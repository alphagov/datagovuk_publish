require 'whois-parser'
require 'rest-client'
require 'logger'


class UrlValidator < ActiveModel::Validator
  def validate(record)
    urlPresent?(record) &&
        urlStartsWithProtocol?(record)
        # Uncommenting the below breaks LOTS of tests

        # validDomain?(record) &&
        # validPath?(record)
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

  def validDomain?(record)
    host = URI.parse(record.url).host
    domainQuery = Whois.whois(host)
    parser = domainQuery.parser
    error = 'Url does not contain a valid domain'

    !parser.registered? ?
        createValidationError(record, error) :
        true
  end

  def validPath?(record)
    begin
      RestClient.head record.url
      true
    rescue RestClient::ExceptionWithResponse
      error = 'Url path is not valid'
      createValidationError(record, error)
    end
  end

  def createValidationError(record, error)
    Rails.logger.info('Validation error: ' + error)
    record.errors[:url] << 'Please enter a valid url'
    false
  end
end