class QualityScore
  attr_reader :reasons

  def initialize(dataset)
    @dataset = dataset
    @reasons = []
  end

  # Obtain a quality score for the dataset out of a maximum of 100.
  # Points are removed for each failing feature of the dataset.
  def score
    value = 100

    methods = QualityScore.instance_methods.grep(/.*_score/)
    methods.each do | f |
      value -= self.send(f)
    end

    value
  end

  def frequency_score
    if @dataset.frequency.blank?
      @reasons << "This dataset has no update frequency set"
      10
    else
      0
    end
  end

  def documentation_score
    if @dataset.docs.count() == 0
      @reasons << "There is no documentation for this data"
      5
    else
      0
    end
  end

  def resource_score
    links = @dataset.links.all()

    # Are there any links at all?
    current = if links.size() == 0
                @reasons << "There are no data links in this dataset"
                10
              else
                0
              end

    # Are any links broken?
    broken = links.select {|link| link.broken }
    if broken.size() > 0
      @reasons << "There are broken links in this dataset"
      current += 10
    end

    current
  end

  def summary_score
    if @dataset.summary.strip() == ""
      @reasons << "This dataset has no summary"
      10
    else
      0
    end

  end

  def additional_notes_score
    return 0 if @dataset.description.blank?
    current = 0

    if @dataset.description.length < 100
      @reasons << "The additional information is very short"
      current += 5
    end

    current
  end

  def contacts_score
    org = @dataset.organisation
    if org.contact_email.blank? && org.contact_phone.blank? && org.contact_name.blank?
      @reasons << "The organisation has no contact details"
      10
    else
      0
    end
  end

  def licence_score
    if @dataset.licence.blank?
      @reasons << "This dataset has no licence"
      10
    else
      0
    end
  end


end
