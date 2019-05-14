RSpec.describe Healthcheck::RecurringJobs::CKANOrgSync do
  subject { described_class.new }
  let(:sidekiq_redis) { SidekiqScheduler::RedisManager }

  describe '#name' do
    it "returns the correct job's name" do
      expect(subject.name).to eq(:CKAN_org_sync)
    end
  end

  describe '#status' do
    before do
      allow(sidekiq_redis).to receive(:get_job_last_time).and_return(when_last_run)
    end

    context 'when the job was last run less than 25 hours ago' do
      let(:when_last_run) { String(24.hours.ago) }

      it 'returns status :ok' do
        expect(subject.status).to eq(:ok)
      end
    end

    context 'when the job was last run 24 or more hours ago' do
      let(:when_last_run) { String(27.hours.ago) }

      it 'returns status :warning' do
        expect(subject.status).to eq(:warning)
      end
    end

    context 'when the job was last run 41 or more hours ago' do
      let(:when_last_run) { String(30.hours.ago) }

      it 'returns status :critical' do
        expect(subject.status).to eq(:critical)
      end
    end
  end

  describe '#details' do
    let(:when_last_run) { String(Time.zone.now) } # any time is ok for this test

    before do
      allow(sidekiq_redis).to receive(:get_job_last_time).and_return(when_last_run)
    end

    it 'returns the currect values' do
      expect(subject.details).to eq(
        critical: when_last_run,
        warning: when_last_run
      )
    end
  end

  describe '#message' do
    let(:when_last_run) { String(Time.zone.local(2019, 4, 16, 23, 10)) } # any time is ok for this test
    let(:message) { "The job 'ckan_v26_ckan_org_sync' should run every 1 day. It was last run 2019-04-16 23:10:00 UTC." }

    before do
      allow(sidekiq_redis).to receive(:get_job_last_time).and_return(when_last_run)
    end

    it 'returns the correct message' do
      expect(subject.message).to eq(message)
    end
  end
end
