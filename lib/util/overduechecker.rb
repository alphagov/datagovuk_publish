module OverdueChecker
  mattr_accessor :frequencies, default: { "monthly" => 30, "annually" => 365, "quarterly" => 90 }

  # Checks the dataset to see if it has a frequency, and whether the
  # datafiles are up to date.
  def check_dataset(dataset)
    puts "Checking dataset #{dataset.title} (#{dataset.name})"

    # If there is no frequency, then we bail quickly
    return unless frequencies.key? dataset.frequency

    # Skip if there is already a task for this dataset
    return if Task.find_by(related_object_id: dataset.uuid,
                           category: "overdue")

    # Finds the max end_date from the datafiles, then determines the
    # number of days since that end_date.
    max_end_date = find_end_date(dataset)
    diff_days = (Time.now - max_end_date).to_i

    # Check if the number of days since most recent datafile is >
    # size of frequency (so > 30 for monthly, 365 for annual etc).
    if diff_days > frequencies[dataset.frequency]
      puts "Creating task for #{dataset.name}"
      create_overdue_task(dataset, diff_days)
    end
  end

  # Creates a new task for the overdue dataset, specifying when it
  # should have been updated.
  def create_overdue_task(dataset, days)
    org = Organisation.find_by(id: dataset.organisation_id)

    t = Task.new
    t.organisation_id = org.id
    t.owning_organisation = org.name
    t.required_permission_name = ""
    t.category = "overdue"
    t.quantity = days
    t.related_object_id = dataset.uuid
    t.created_at = t.updated_at = Time.now
    t.description = "'#{dataset.title}' is overdue"
    t.save
  end

  # Find the lastest end_date in the datafiles for this dataset and return
  # it.
  def find_end_date(dataset)
    Link
      .where(dataset_id: dataset.id)
      .all
      .inject(Date.parse("2000-01-01")) { |acc, datafile| [datafile.end_date, acc].max }
  end

  module_function :check_dataset, :find_end_date, :create_overdue_task
end
