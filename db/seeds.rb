# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

# Add default topics.  This is required before you can import the legacy metadata
# so that we don't lose data in the migration

if Topic.count.zero?
  Topic.create(
    [
      { name: "business-and-economy", title: "Business and economy" },
      { name: "environment", title: "Environment" },
      { name: "mapping", title: "Mapping" },
      { name: "crime-and-justice", title: "Crime and justice" },
      { name: "government", title: "Government" },
      { name: "society", title: "Society" },
      { name: "defence", title: "Defence" },
      { name: "government-spending", title: "Government spending" },
      { name: "towns-and-cities", title: "Towns and cities" },
      { name: "education", title: "Education" },
      { name: "health", title: "Health" },
      { name: "transport", title: "Transport" },
    ]
  )
end

puts 'Seeded topics'

# We can create land-registry now, and if we import organisations
# then they will just update it.
land_registry = Organisation.new
land_registry.name = "land-registry"
land_registry.title = "Land Registry"
land_registry.save!

hmrc = Organisation.new
hmrc.name = "hmrc"
hmrc.title = "hmrc"
hmrc.save!

puts 'Seeded organisations'

# Land Registry User
User.create!(
  name: 'Admin',
  email: 'admin@example.com',
  uid: 1
)

puts 'Seeded users'

# Locations
location_csv_text = File.read('lib/seeds/locations.csv')
location_csv = CSV.parse(location_csv_text, headers: true)
location_csv.each do |row|
  Location.create!(row.to_hash)
end

puts 'Seeded locations'
