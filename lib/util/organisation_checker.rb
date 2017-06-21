module OrganisationChecker
  def check_organisation(organisation)
    puts "Checking datasets for #{organisation.title}"
    Dataset.where(:organisation_id => organisation.id).find_each(:batch_size => 10) do |dataset|
      check_dataset(dataset)
    end
  end
end
