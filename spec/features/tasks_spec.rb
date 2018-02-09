require 'rails_helper'

describe "viewing tasks" do
  let(:land_registry) { FactoryGirl.create(:organisation, title: 'Land Registry') }
  let(:user) { FactoryGirl.create(:user, primary_organisation_id: land_registry.id ) }
  let!(:fix_task) { FactoryGirl.create(:task, category: 'broken', organisation: land_registry ) }
  let!(:update_task) { FactoryGirl.create(:task, category: 'overdue', organisation: land_registry ) }
  let!(:dataset) { FactoryGirl.create(:dataset, name: 'my_dataset', title: 'My  Dataset', summary: 'Some data', organisation: land_registry ) }

  it "after login" do
    create_user_and_sign_in
    expect(page).to have_current_path '/tasks'
    click_link 'Land Registry tasks'
    expect(page).to have_selector(%(table), count: 2)
    expect(page).to have_selector 'h2', text: '1 datasets need to be updated'
    expect(page).to have_selector 'h2', text: '1 datasets have broken data links'
  end
end
