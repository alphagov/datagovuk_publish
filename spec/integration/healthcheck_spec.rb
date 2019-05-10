RSpec.describe 'Healthcheck', type: :request do
  def data(body = response.body)
    JSON.parse(body).deep_symbolize_keys
  end

  let(:sidekiq_redis) { SidekiqScheduler::RedisManager }
  let(:message) { "The job 'ckan_v26_package_sync' should run every 10 minutes. It was last run #{when_last_run}." }
  let(:expected_data) do
    {
      status: status,
      checks: {
        package_sync: {
          critical: when_last_run,
          warning: when_last_run,
          status: status,
          message: message
        }
      }
    }
  end

  before do
    allow(sidekiq_redis).to receive(:get_job_last_time).and_return(when_last_run)
  end

  context 'when the healthchecks pass' do
    let(:when_last_run) { String(10.minutes.ago) }
    let(:status) { 'ok' }

    it "returns a status of 'ok'" do
      get '/healthcheck'
      expect(data).to eq(expected_data)
    end
  end

  context 'when one of the healthchecks is warning' do
    let(:when_last_run) { String(12.minutes.ago) }
    let(:status) { 'warning' }

    it "returns a status of 'warning'" do
      get '/healthcheck'
      expect(data).to eq(expected_data)
    end
  end

  context 'when one of the healthchecks is critical' do
    let(:when_last_run) { String(70.minutes.ago) }
    let(:status) { 'critical' }

    it "returns a status of 'critical'" do
      get '/healthcheck'
      expect(data).to eq(expected_data)
    end
  end
end
