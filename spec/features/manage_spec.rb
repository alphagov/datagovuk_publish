require 'rails_helper'

describe "managing datasets" do
  before(:each) do
    o = Organisation.new
    o.name = 'land-registry'
    o.title = 'Land Registry'
    o.save!()

    User.create!(email:'test@localhost',
                 primary_organisation: o,
                 password: 'password',
                 password_confirmation: 'password')

    price_paid_dataset = Dataset.create!(
      name: 'price paid data',
      title: 'Price Paid data for all London Boroughs',
      summary: 'Price Paid Data tracks the residential property sales in England and Wales that are lodged with HM Land Registry for registration. ',
      organisation: o
    )
  end

  it "after login" do
    visit '/'
    click_link 'Sign in'
    fill_in('user_email', with: 'test@localhost')
    fill_in('Password', with: 'password')
    click_button 'Sign in'
    expect(page).to have_current_path '/tasks'

    # Don't expect any tables as creator_id not set on dataset
    click_link 'Manage datasets'
    expect(page).to have_selector(%(table), count: 0)

    # Expect to see the table with datasets in it.
    click_link 'Land Registry datasets'
    expect(page).to have_selector(%(table), count: 1)
  end
end
