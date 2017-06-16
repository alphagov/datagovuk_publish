# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# We can create land-registry now, and if we import organisations
# then they will just update it.
land_registry = Organisation.new
land_registry.name = "land-registry"
land_registry.title = "Land Registry"
land_registry.save!()

hmrc = Organisation.new
hmrc.name = "hmrc"
hmrc.title = "hmrc"
hmrc.save!()

admin = AdminUser.create!(
  email: 'admin@example.com',
  name: 'Administrator',
  password: 'password',
  password_confirmation: 'password'
)

lr_publisher = User.create!(
  email: 'publisher@example.com',
  name: 'Publisher',
  password: 'password',
  password_confirmation: 'password',
  primary_organisation: land_registry
)

hmrc_publisher = User.create!(
  email: 'hmrc_publisher@example.com',
  name: 'HMRC',
  password: 'password',
  password_confirmation: 'password',
  primary_organisation: hmrc
)

fix_task = Task.create!(
  organisation: land_registry,
  description: 'fix this task'
)

update_task = Task.create!(
  organisation: land_registry,
  description: 'update this task'
)

price_paid_dataset = Dataset.create!(
  name: 'price paid data',
  title: 'Price Paid data for all London Boroughs',
  summary: 'Price Paid Data tracks the residential property sales in England and Wales that are lodged with HM Land Registry for registration. ',
  organisation: land_registry
)

hmrc_spending_dataset = Dataset.create!(
  name: 'HMRC spending',
  title: 'HMRC spending over £25000',
  summary: 'Monthly details of HMRC’s spending with suppliers covering transactions over £25,000',
  organisation: land_registry
)

council_tax_bands = Dataset.create!(
  name: 'Council Tax',
  title: 'Council Tax bands for London',
  summary: 'Council tax bands for the current year',
  organisation: land_registry
)

for i in 1..5
  Dataset.create!(
  name: "LR_Dataset_#{i} name",
  title: "LR_Dataset_#{i} title",
  summary: "LR_Dataset_#{i} summary",
  organisation: land_registry
  )
end

for i in 1..5
  Dataset.create!(
  name: "HMRC_Dataset_#{i} name",
  title: "HMRC_Dataset_#{i} title",
  summary: "HMRC_Dataset_#{i} summary",
  organisation: hmrc
  )
end
