module OrganisationChecker
  def check_organisation(organisation)
    puts "Checking datasets for #{organisation.title}"
    datasets = Dataset.includes(:organisation_id => organisation.id)
    datasets.find_each(:batch_size => 10) do |dataset|
      check_dataset(dataset)
    end
  end
end
