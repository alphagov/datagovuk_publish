require Rails.root.join('app/presenters/publishing_api_presenter')

class PublishingApiWorker
  include Sidekiq::Worker

  def perform(dataset_id, update_type = "major")
    dataset = Dataset.find(dataset_id)
    presenter = PublishingApiPresenter.new(dataset, update_type)
    payload = presenter.render
    PublishingApiService.client.put_content(dataset.uuid, payload)
    PublishingApiService.client.publish(dataset.uuid, update_type)
  end
end

