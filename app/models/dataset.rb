class Dataset < ApplicationRecord
  extend FriendlyId

  belongs_to :organisation
  has_many :datafiles
  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name

  validates :frequency, inclusion: %w(daily weekly monthly quarterly annually financial-year never),
                        allow_nil: true # To allow creation before setting this value

  validates :title,
    presence: { message: "Please enter a valid title" }

  validates :summary,
    presence: { message: "Please provide a summary" }

  validates :frequency,
    :presence => { message: "Please indicate how often this dataset is updated" },
    :if => lambda { published }

  validates :licence,
    :presence => { message: "Please select a licence for your dataset" },
    :if => lambda{ published }

  validate :dataset_must_have_datafiles_validation,
    :if => lambda{ published }

  def owner
    User.find(id: self.owner_id)
  end

  def owner=(user)
    self.owner_id = user.id
  end

  def creator
    User.find(id: self.creator_id)
  end

  def creator=(user)
    self.creator_id = user.id
  end

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

  def daily?
    frequency == 'daily'
  end

  def weekly?
    frequency == 'weekly'
  end

  def monthly?
    frequency == 'monthly'
  end

  def quarterly?
    frequency == 'quarterly'
  end

  def annually?
    frequency == 'annually'
  end

  def financial_yearly?
    frequency == 'financial-year'
  end

  def never?
    frequency == 'never'
  end

  def one_off?
    never?
  end
end
