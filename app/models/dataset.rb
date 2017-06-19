class Dataset < ApplicationRecord
  extend FriendlyId

  belongs_to :organisation
  has_many :datafiles
  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name

  validates :title, presence: true
  validates :summary, presence: true

  validates :licence,
    :presence => true,
    :if => lambda{ published }

  validates :frequency,
    :presence => true,
    :if => lambda{ published }

  validate :dataset_must_have_datafiles_validation,
    :if => lambda{ published }


  def slug_candidates
    [:title, :title_and_sequence]
  end

  def title_and_sequence
    slug = title.to_param
    sequence = Dataset.where("name like ?", "#{slug}-%").count + 2
    "#{slug}-#{sequence}"
  end

  def published?
    published
  end

  def status
    if published?
      "Published"
    else
      "Draft"
    end
  end

  def dataset_must_have_datafiles_validation
    if self.datafiles.count() == 0
      errors.add(:base, "Dataset must have at least one data file")
    end
  end

end
