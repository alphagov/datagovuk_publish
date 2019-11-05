RSpec.describe "Healthcheck", type: :request do
  def data(body = response.body)
    JSON.parse(body).deep_symbolize_keys
  end

  let(:sidekiq_redis) { SidekiqScheduler::RedisManager }

  context "when the healthchecks pass" do
    let(:when_last_run) { String(10.minutes.ago) }
    before do
      allow(sidekiq_redis).to receive(:get_job_last_time).and_return(when_last_run)
    end

    it "returns a status of 'ok'" do
      get "/healthcheck"
      expect(data.fetch(:status)).to eq("ok")
    end
  end

  context "when one of the healthchecks is warning" do
    let(:when_last_run) { String(12.minutes.ago) }
    before do
      allow(sidekiq_redis).to receive(:get_job_last_time).and_return(when_last_run)
    end

    it "returns a status of 'warning'" do
      get "/healthcheck"
      expect(data.fetch(:status)).to eq("warning")
    end
  end

  context "when one of the healthchecks is critical" do
    let(:when_last_run) { String(70.minutes.ago) }
    before do
      allow(sidekiq_redis).to receive(:get_job_last_time).and_return(when_last_run)
    end

    it "returns a status of 'critical'" do
      get "/healthcheck"
      expect(data.fetch(:status)).to eq("critical")
    end
  end

  let(:when_package_sync_last_run) { String(10.minutes.ago) }
  let(:when_ckan_org_sync_last_run) { String(24.hours.ago) }

  it "includes useful information about each check" do
    allow(sidekiq_redis).to receive(:get_job_last_time).with("ckan_v26_package_sync").and_return(when_package_sync_last_run)
    allow(sidekiq_redis).to receive(:get_job_last_time).with("ckan_v26_ckan_org_sync").and_return(when_ckan_org_sync_last_run)

    get "/healthcheck"

    expect(data.fetch(:checks)).to include(
      package_sync:  { critical: when_package_sync_last_run,
                       warning: when_package_sync_last_run,
                       status: "ok",
                       message: "The job 'ckan_v26_package_sync' should run every 10 minutes. It was last run #{when_package_sync_last_run}." },
      CKAN_org_sync: { critical: when_ckan_org_sync_last_run,
                       warning: when_ckan_org_sync_last_run,
                       status: "ok",
                       message: "The job 'ckan_v26_ckan_org_sync' should run every 1 day. It was last run #{when_ckan_org_sync_last_run}." }
    )
  end
end
