require 'rails_helper'

describe DatasetsController, type: :controller do
  let(:organisation) { FactoryBot.create(:organisation) }
  let(:user) { FactoryBot.create(:user, primary_organisation: organisation) }

  before do
    sign_in_as(user)
  end

  it "redirects to slugged URL" do
    dataset = FactoryBot.create(
      :dataset,
      name: "legit-name",
      organisation: organisation,
      datafiles: [FactoryBot.create(:datafile)]
    )

    get :show, params: { uuid: dataset.uuid, name: "absolute-nonsense-name" }

    expect(response).to redirect_to(dataset_url(dataset.uuid, dataset.name))
  end

  it "returns '503 forbidden' error if a user is not allowed to view the requested dataset" do
    another_organisation = FactoryBot.create(:organisation)

    _allowed_dataset = FactoryBot.create(
      :dataset,
      organisation: organisation,
      datafiles: [FactoryBot.create(:datafile)]
    )

    forbidden_dataset = FactoryBot.create(
      :dataset,
      organisation: another_organisation,
      datafiles: [FactoryBot.create(:datafile)]
    )

    get :show, params: { uuid: forbidden_dataset.uuid, name: forbidden_dataset.name }

    expect(response).to have_http_status(403)
  end

  it "returns '503 forbidden' error if a user is not allowed to update the requested dataset" do
    another_organisation = FactoryBot.create(:organisation)

    _allowed_dataset = FactoryBot.create(
      :dataset,
      organisation: organisation,
      datafiles: [FactoryBot.create(:datafile)]
    )

    forbidden_dataset = FactoryBot.create(
      :dataset,
      organisation: another_organisation,
      datafiles: [FactoryBot.create(:datafile)]
    )

    get :edit, params: { uuid: forbidden_dataset.uuid, name: forbidden_dataset.name }

    expect(response).to have_http_status(403)
  end
end
