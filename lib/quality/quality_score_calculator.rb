class QualityScoreCalculator
  attr_reader :reasons

  def initialize(dataset)
    @dataset = dataset
    @reasons = []
  end

  # Obtain a quality score for the dataset out of a maximum of 100.
  # Points are removed for each failing feature of the dataset.
  def score
    value = 100

    methods = QualityScoreCalculator.instance_methods.grep(/.*_score/)
    methods.each do | f |
      value -= self.send(f)
    end

    value
  end

  def frequency_score
    if @dataset.frequency.blank?
      @reasons << "This dataset has no update frequency set"
      20
    else
      0
    end
  end

  def documentation_score
    if @dataset.docs.count.zero?
      @reasons << "There is no documentation for this data"
      5
    else
      0
    end
  end

  def resource_score
    links = @dataset.links.all

    # Are there any links at all?
    current = if links.size.zero?
                @reasons << "There are no data links in this dataset"
                20
              else
                0
              end

    # Are any links broken?
    broken = links.select(&:broken)
    if broken.size.positive?
      @reasons << "There are broken links in this dataset"
      current += 15
    end

    current
  end

  def summary_score
    if @dataset.summary.strip == ""
      @reasons << "This dataset has no summary"
      15
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
      15
    else
      0
    end
  end

  def licence_score
    if @dataset.licence.blank?
      @reasons << "This dataset has no licence"
      15
    else
      0
    end
  end
end
