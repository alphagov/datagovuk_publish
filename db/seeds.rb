# coding: utf-8

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

land_registry = Organisation.create!(
  name: 'land-registry',
  title: 'Land Registry'
)

hmrc = Organisation.create(
  name: 'hmrc',
  title: 'hmrc'
)

puts 'Seeded organisations'

User.create!(
  email: 'publisher@example.com',
  name: 'Publisher',
  primary_organisation: land_registry
)

User.create!(
  email: 'hmrc_publisher@example.com',
  name: 'HMRC',
  primary_organisation: hmrc
)

puts 'Seeded users'

location_csv_text = File.read('lib/seeds/locations.csv')
location_csv = CSV.parse(location_csv_text, headers: true)
location_csv.each do |row|
  Location.create!(row.to_hash)
end

puts 'Seeded locations'
