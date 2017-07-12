require 'elasticsearch/model'

class Dataset < ApplicationRecord
  include Elasticsearch::Model
  extend FriendlyId

  index_name    "datasets-#{Rails.env}"
  document_type "dataset"

  belongs_to :organisation
  has_many :datafiles
  has_one :inspire_dataset

  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name

  validates :frequency, inclusion: %w(daily weekly monthly quarterly annually financial-year never),
                        allow_nil: true # To allow creation before setting this value

  validates :title,
    presence: { message: "Please enter a valid title" }

  validates_format_of :title, {
    with: /([a-z]){3}.*/i,
    message: "Please enter a valid title"
  }

  validates :summary,
    presence: { message: "Please provide a summary" }

  validates :frequency,
    presence: { message: "Please indicate how often this dataset is updated" },
    if: lambda { published }

  validates :licence,
    presence: { message: "Please select a licence for your dataset" },
    inclusion: %w(uk-ogl other),
    if: lambda{ published }

  validates :licence_other,
    presence: { message: "Please type the name of your licence" },
    allow_blank: false,
    if: lambda { licence == 'other' }

  validate :published_dataset_must_have_datafiles_validation

  # What we actually want to index in Elastic, rather than the whole
  # dataset.
  def as_indexed_json(_options={})
    as_json(
      only: [:name, :title, :summary, :description,
             :location1, :location2, :location3,
             :licence, :licence_other, :frequency,
             :published_date, :updated_at, :created_at,
             :harvested, :uuid],
      include: {
        organisation: {},
        datafiles: {},
        inspire_dataset: {}
      }
    )
  end

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

  def published_dataset_must_have_datafiles_validation
    if self.published && self.datafiles.datalinks.empty?
      errors.add(:files, "You must add at least one link")
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
