# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin = AdminUser.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password')

publisher = User.create!(
  email: 'publisher@example.com',
  password: 'password',
  password_confirmation: 'password',
  primary_organisation: Organisation.new(
    name: 'Land Registry'
  )
)

fix_task = Task.create!(
  organisation: Organisation.new,
  description: 'fix this task'
)

update_task = Task.create!(
  organisation: Organisation.new,
  description: 'update this task'
)

price_paid_dataset = Dataset.create!(
  name: 'price paid data',
  title: 'Price Paid data for all London Boroughs',
  summary: 'Price Paid Data tracks the residential property sales in England and Wales that are lodged with HM Land Registry for registration. ',
  organisation: Organisation.new
)

hmrc_spending_dataset = Dataset.create!(
  name: 'HMRC spending',
  title: 'HMRC spending over £25000',
  summary: 'Monthly details of HMRC’s spending with suppliers covering transactions over £25,000',
  organisation: Organisation.new
)

council_tax_bands = Dataset.create!(
  name: 'Council Tax',
  title: 'Council Tax bands for London',
  summary: 'Council tax bands for the current year',
  organisation: Organisation.new
)
