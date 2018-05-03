class AddUserStudyOrgMappings < ActiveRecord::Migration[5.1]
  def change
    mappings = {
      "de4e9dc6-cca4-43af-a594-682023b84d6c" => "a7059f6a-7fb4-4e0f-9c7a-8cd9079780d3", # department-for-environment-food-rural-affairs"
      "60de9b00-a982-4449-a995-f2353e86fb95" => "7e905728-3b43-4e44-9253-034af65738bc", # higher-education-statistical-agency
      "4c717efc-f47b-478e-a76d-ce1ae0af1946" => "e4900b3b-a7f8-447a-bd5e-43735f8f1b4a" # department-for-transport
    }

    mappings.each do |govuk_content_id, uuid|
      org = Organisation.find_by(uuid: uuid)
      next unless org
      org.update_attribute(:govuk_content_id, govuk_content_id)
    end
  end
end
