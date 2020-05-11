require "csv"

puts "Seeding topics"
Topic.find_or_create_by(name: "business-and-economy", title: "Business and economy")
Topic.find_or_create_by(name: "environment", title: "Environment")
Topic.find_or_create_by(name: "mapping", title: "Mapping")
Topic.find_or_create_by(name: "crime-and-justice", title: "Crime and justice")
Topic.find_or_create_by(name: "government", title: "Government")
Topic.find_or_create_by(name: "society", title: "Society")
Topic.find_or_create_by(name: "defence", title: "Defence")
Topic.find_or_create_by(name: "government-spending", title: "Government spending")
Topic.find_or_create_by(name: "towns-and-cities", title: "Towns and cities")
Topic.find_or_create_by(name: "education", title: "Education")
Topic.find_or_create_by(name: "health", title: "Health")
Topic.find_or_create_by(name: "transport", title: "Transport")

puts "Seeding organisations"
org = Organisation.find_or_create_by(uuid: "90aefa0d-0e92-4895-a7fd-c1adb2b3f14f",
                                     name: "government-digital-service")

org.update_attribute(:govuk_content_id, "af07d5a5-df63-4ddc-9383-6a666845ebe9")
org.update_attribute(:title, "Government Digital Service")

puts "Seeding users"
User.find_or_create_by(email: "publisher@example.com",
                       name: "Publisher",
                       organisation_content_id: org.govuk_content_id)
