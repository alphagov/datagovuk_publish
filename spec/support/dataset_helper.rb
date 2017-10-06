def edit_dataset(dataset)
  datasets = {
    :unfinished_dataset => 0,
    :unpublished_dataset => 1,
    :published_dataset => 2
  }
  index = datasets[dataset]
  all(:link, "Edit")[index].click
end

def click_change(property)
  properties = {
    :title => 0,
    :summary => 1,
    :additional_info => 2,
    :licence => 3,
    :location => 4,
    :frequency => 5,
    :datalinks => 6,
    :documentation => 7
  }
  index = properties[property]
  all(:link, "Change")[index].click
end

def set_up_models

    let(:land) { FactoryGirl.create(:organisation, name: 'land-registry', title: 'Land Registry') }
    let(:user) { FactoryGirl.create(:user, primary_organisation: land) }
    let(:published_dataset) { FactoryGirl.create(:dataset,
                                                  title: 'test title published',
                                                  summary: 'test summary',
                                                  organisation: land,
                                                  location1: 'somewhere',
                                                  frequency: 'never',
                                                  licence: 'uk-ogl',
                                                  status: "published",
                                                  last_updated_at: Time.now,
                                                  links: [FactoryGirl.create(:link, name: "my published test file")],
                                                  docs: [FactoryGirl.create(:doc, name: "my published test doc")],
                                                  creator: user,
                                                  owner: user) }

    let(:unpublished_dataset) { FactoryGirl.create(:dataset,
                                                    title: 'test title unpublished',
                                                    summary: 'test summary',
                                                    organisation: land,
                                                    frequency: 'never',
                                                    licence: 'uk-ogl',
                                                    location1: 'somewhere',
                                                    status: "draft",
                                                    last_updated_at: Time.now,
                                                    links: [FactoryGirl.create(:link, name: "my published test file")],
                                                    docs: [FactoryGirl.create(:doc, name: "my published test doc")],
                                                    creator: user,
                                                    owner: user ) }


    let(:unfinished_dataset) { FactoryGirl.create(:dataset,
                                                   organisation: land,
                                                   creator: user,
                                                   owner: user,
                                                   last_updated_at: Time.now,
                                                   title: 'test title unfinished',
                                                   summary: 'test summary') }

end

def build_datasets
  published_dataset
  unpublished_dataset
  unfinished_dataset
end
