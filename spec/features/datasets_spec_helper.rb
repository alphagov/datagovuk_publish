def set_up
  # let! used here to force it to eager evaluate before each test
  let! (:org)  { Organisation.create!(name: "land-registry", title: "Land Registry") }
  let! (:user) do
     User.create!(email: "test@localhost",
                  name: "Test User",
                  primary_organisation: org,
                  password: "password",
                  password_confirmation: "password")
  end
  let! (:unfinished_dataset) do
    Dataset.create!(
      organisation: org,
      title: 'test title unfinished',
      summary: 'test summary',
      creator: user,
      owner: user
    )
  end

  let! (:unpublished_dataset) do
    d = Dataset.create!(
      organisation: org,
      title: 'test title unpublished',
      summary: 'test summary',
      frequency: 'never',
      licence: 'uk-ogl',
      location1: 'somewhere',
      published: false,
      creator: user,
      owner: user
    )

    d.datafiles << Datafile.create!(url: 'http://localhost', name: 'my test file', dataset: d)
    d.datafiles << Datafile.create!(url: 'http://localhost/doc', name: 'my test doc', dataset: d, documentation: true)
    d.save

    d
  end

  let! (:published_dataset) do
    d = Dataset.create!(
      organisation: org,
      title: 'test title published',
      summary: 'test summary',
      frequency: 'never',
      licence: 'uk-ogl',
      location1: 'here',
      published: false,
      creator: user,
      owner: user
    )

    d.datafiles << Datafile.create!(url: 'http://localhost', name: 'my published test file', dataset: d)
    d.datafiles << Datafile.create!(url: 'http://localhost/doc', name: 'my published test doc', dataset: d, documentation: true)
    d.published = true
    d.save

    d
  end
end

def sign_in
  visit "/"
  click_link "Sign in"
  fill_in("user_email", with: "test@localhost")
  fill_in("Password", with: "password")
  click_button "Sign in"
end


def edit_dataset(dataset)
  datasets = {
    :published_dataset => 0,
    :unpublished_dataset => 1,
    :unfinished_dataset => 2
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
