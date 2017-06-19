class Dataset < ApplicationRecord
  extend FriendlyId

  belongs_to :organisation
  has_many :datafiles
  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name

  validates :title,
    presence: { message: "Please enter a valid title" },
    length: { maximum: 100, message: "Ensure this value has at most 100 characters" }

  validates :summary,
    presence: { message: "Please enter a valid summary" },
    length: { maximum: 200, message: "Ensure this value has at most 200 characters" }

  validates :frequency,
    :presence => { message: "Please indicate how often this dataset is updated" },
    :if => lambda { published }

  validates :licence,
    :presence => { message: "Please select a licence for your dataset" },
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
      errors.add(:base, "You must add at least one link")
    end
  end

end
