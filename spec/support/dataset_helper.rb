def click_change(property)
  find("#edit_#{property}").click
end

def click_dataset(dataset)
  find(:xpath, "//a[@href='#{dataset_path(dataset.uuid, dataset.name)}']").click
end

def set_up_models

    let(:land) { FactoryGirl.create(:organisation) }
    let(:user) { FactoryGirl.create(:user, primary_organisation: land) }

    let(:published_dataset) { FactoryGirl.create(:dataset,
                                                  organisation: land,
                                                  status: "published",
                                                  links: [FactoryGirl.create(:link)],
                                                  docs: [FactoryGirl.create(:doc)],
                                                  creator: user,
                                                  owner: user) }

    let(:unpublished_dataset) { FactoryGirl.create(:dataset,
                                                    organisation: land,
                                                    status: "draft",
                                                    links: [FactoryGirl.create(:link)],
                                                    docs: [FactoryGirl.create(:doc)],
                                                    creator: user,
                                                    owner: user ) }


    let(:unfinished_dataset) { FactoryGirl.create(:dataset,
                                                   organisation: land,
                                                   creator: user,
                                                   owner: user) }

end

def build_datasets
  published_dataset
  unpublished_dataset
  unfinished_dataset
end
