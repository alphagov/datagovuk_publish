module Healthcheck
  module RecurringJobs
    class CKANOrgSync
      include ActionView::Helpers::DateHelper

      JOB_NAME = 'ckan_v26_ckan_org_sync'.freeze
      JOB_FREQUENCY = 24.hours
      WARNING_DELAY = 3.hours # After 11 retries
      CRITICAL_DELAY = 6.hours # After 13 retries and Sidekiq stops retrying

      def name
        :CKAN_org_sync
      end

      def status
        if Time.zone.parse(when_last_run) <= critical_latency
          :critical
        elsif Time.zone.parse(when_last_run) <= warning_latency
          :warning
        else
          :ok
        end
      end

      def details
        {
          critical: when_last_run,
          warning: when_last_run
        }
      end

      def message
        "The job '#{JOB_NAME}' should run every #{distance_of_time_in_words(JOB_FREQUENCY)}. It was last run #{when_last_run}."
      end

    private

      def when_last_run
        SidekiqScheduler::RedisManager.get_job_last_time(JOB_NAME)
      end

      def critical_latency
        (JOB_FREQUENCY + CRITICAL_DELAY).ago
      end

      def warning_latency
        (JOB_FREQUENCY + WARNING_DELAY).ago
      end
    end
  end
end
