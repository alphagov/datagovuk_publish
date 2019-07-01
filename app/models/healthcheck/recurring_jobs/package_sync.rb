module Healthcheck
  module RecurringJobs
    class PackageSync
      include ActionView::Helpers::DateHelper

      JOB_NAME = 'ckan_v26_package_sync'.freeze
      JOB_FREQUENCY = 10.minutes
      WARNING_DELAY = 2.minutes
      CRITICAL_DELAY = 1.hour

      def name
        :package_sync
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
