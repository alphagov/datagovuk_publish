require 'rails_helper'

describe "viewing tasks" do
  before(:each) do
    o = Organisation.new
    o.name = 'land-registry'
    o.title = 'Land Registry'
    o.save!()

    User.create!(email:'test@localhost',
                 primary_organisation: o,
                 password: 'password',
                 password_confirmation: 'password')

    fix_task = Task.create!(
      organisation: o,
      description: 'fix this task'
    )

    update_task = Task.create!(
      organisation: o,
      description: 'update this task'
    )

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

    click_link 'Land Registry tasks'
    expect(page).to have_selector(%(table), count: 2)
    expect(page).to have_selector 'h2', :text => '2 datasets need to be updated'
    expect(page).to have_selector 'h2', :text => '1 datasets have broken data links'

  end
end
