module CKAN
  module V26
    class Depaginator
      include CKAN::Modules::URLBuilder
      MAX_DELETIONS = 15_647

      def self.depaginate(*args, **kwargs)
        new(*args, **kwargs).depaginate
      end

      def initialize(base_url, existing_total:)
        @base_url = base_url
        @existing_total = existing_total
        @results = []
      end

      def depaginate
        loop do
          url = append_url(base_url, params: { "start" => results.count })
          begin
            raw_response = url.read
            response = JSON.parse(raw_response)
            result = response.fetch("result")
            page = result.fetch("results")
            total_expected = result.fetch("count")
            total_expected_from_first_response ||= total_expected

            if total_expected != total_expected_from_first_response
              raise ExpectedTotalChangedError, <<~MESSAGE
                New expected count `#{total_expected}` from CKAN does not match
                the original expected count of `#{total_expected_from_first_response}`.

                CKAN response:
                #{raw_response}
              MESSAGE
            end

            results.concat(page)

            if results.count > total_expected
              raise MoreResultsThanExpectedError, <<~MESSAGE
                We have received more results (#{results.count}) than expected (#{total_expected}).

                CKAN response:
                #{raw_response}
              MESSAGE
            end

            if page.empty?
              if results.count == total_expected
                number_being_deleted = existing_total - results.count

                if number_being_deleted <= MAX_DELETIONS
                  break
                else
                  raise DeletionTooLargeError, <<~MESSAGE
                    Attempting to delete `#{number_being_deleted}` datasets.

                    No more than #{MAX_DELETIONS} datasets can be deleted at once.

                    CKAN response:
                    #{raw_response}
                  MESSAGE
                end
              else
                raise EarlyEmptyPageError, <<~MESSAGE
                  We have received an empty page but have only received `#{results.count}`
                  results rather than the expected `#{total_expected}` results.

                  CKAN response:
                  #{raw_response}
                MESSAGE
              end
            end
          rescue OpenURI::HTTPError
            logger.error "Problem getting response from #{url}"
          end
        end

        results.reject { |h| h["organization"] == Rails.configuration.test_publisher }
      end

    private

      attr_reader(:base_url, :existing_total, :results)

      class DeletionTooLargeError < StandardError; end

      class ExpectedTotalChangedError < StandardError; end

      class MoreResultsThanExpectedError < StandardError; end

      class EarlyEmptyPageError < StandardError; end
    end
  end
end
