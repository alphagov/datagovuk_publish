# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

# Add default themes.  This is required before you can import the legacy metadata
# so that we don't lose data in the migration

if Theme.count == 0
  Theme.create(
    [
      {name: "business-and-economy", title: "Business and economy"},
      {name: "environment", title: "Environment"},
      {name: "mapping", title: "Mapping"},
      {name: "crime-and-justice", title: "Crime and justice"},
      {name: "government", title: "Government"},
      {name: "society", title: "Society"},
      {name: "defence", title: "Defence"},
      {name: "government-spending", title: "Government spending"},
      {name: "towns-and-cities", title: "Towns and cities"},
      {name: "education", title: "Education"},
      {name: "health", title: "Health"},
      {name: "transport", title: "Transport"},
    ]
  )
end

# We can create land-registry now, and if we import organisations
# then they will just update it.
land_registry = Organisation.find_by(name: 'land-registry')
hmrc = Organisation.find_by(name: 'hmrc')
gds = Organisation.find_by(name: 'government-digital-service')

# Admin
AdminUser.create!(
  email: 'admin@example.com',
  name: 'Administrator',
  password: 'password',
  password_confirmation: 'password'
)

# Land Registry User
User.create!(
  email: 'publisher@example.com',
  name: 'Publisher',
  password: 'password',
  password_confirmation: 'password',
  primary_organisation_id: land_registry.id
)

# HMRC User
User.create!(
  email: 'hmrc_publisher@example.com',
  name: 'HMRC',
  password: 'password',
  password_confirmation: 'password',
  primary_organisation_id: hmrc.id
)

#GDS User
User.create!(
  email: 'gds@example.com',
  name: 'GDS',
  password: 'password',
  'password_confirmation': 'password',
  primary_organisation_id: gds.id
)

# Locations
location_csv_text = File.read('lib/seeds/locations.csv')
location_csv = CSV.parse(location_csv_text, :headers => true)
location_csv.each do |row|
  Location.create!(row.to_hash)
end
