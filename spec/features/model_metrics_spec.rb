require 'rails_helper'

describe ModelMetricsWorker, type: :request do
  let!(:organisation) { FactoryGirl.create :organisation }
  let!(:user) { FactoryGirl.create :user, primary_organisation: organisation }
  let!(:dataset) { FactoryGirl.create :dataset, organisation: organisation }
  let!(:doc) { FactoryGirl.create :doc, dataset: dataset }
  let!(:datafile) { FactoryGirl.create :datafile, dataset: dataset }

  describe '#perform' do
    before do
      subject.perform
      get '/metrics'
    end

    it 'exports model metrics for users' do
      expect(response.body).to match(/datagovuk_publish_user_total{
                                        organisation_slug="land-registry".*
                                      }\ 1/x)
    end

    it 'exports model metrics for datasets' do
      expect(response.body).to match(/datagovuk_publish_dataset_total{
                                        topics.name="business-and-economy",
                                        dataset_type="",
                                        licence_code="uk-ogl",
                                        frequency="never",
                                        organisations.name="land-registry".*
                                      }\ 1/x)
    end

    it 'exports model metrics for links' do
      expect(response.body).to match(/datagovuk_publish_link_total{
                                        format="csv",
                                        type="datafile".*
                                      }\ 1/x)

      expect(response.body).to match(/datagovuk_publish_link_total{
                                        format="",
                                        type="doc".*
                                      }\ 1/x)
    end
  end
end
