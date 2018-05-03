# coding: utf-8

require 'csv'

puts 'Seeding topics'
Topic.create([
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
])

puts 'Seeding organisations'
org = Organisation.create(name: 'government-digital-service',
                                    title: 'Government Digital Service',
                                    govuk_content_id: 'af07d5a5-df63-4ddc-9383-6a666845ebe9')


puts 'Seeding users'
User.create(email: 'publisher@example.com',
            name: 'Publisher',
            primary_organisation: org)


puts 'Seeding locations'
location_csv_text = File.read('lib/seeds/locations.csv')
location_csv = CSV.parse(location_csv_text, headers: true)
location_csv.each { |r| Location.create(r.to_hash) }
