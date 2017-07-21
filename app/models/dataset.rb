require 'elasticsearch/model'

class Dataset < ApplicationRecord
  TITLE_FORMAT = /([a-z]){3}.*/i
  STAGES = %w(initialised completed)

  include Elasticsearch::Model
  extend FriendlyId

  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name
  index_name    "datasets-#{Rails.env}"
  document_type "dataset"

  after_initialize :set_initial_stage
  before_destroy :prevent_if_published

  belongs_to :organisation
  has_many :links
  has_many :docs
  has_one :inspire_dataset

  validates :frequency, inclusion: { in: %w(daily weekly monthly quarterly annually financial-year never) },
                        allow_nil: true # To allow creation before setting this value
  validates :title, presence: true, format: { with: TITLE_FORMAT }
  validates :summary, presence: true
  validates :frequency, presence: true, if: lambda { published }
  validates :licence, presence: true, if: lambda{ published }
  validates :licence_other, presence: true, if: lambda { licence == 'other' }
  validates :stage, inclusion: { in: STAGES }
  validate :published_dataset_must_have_datafiles_validation

  def datafiles
    links + docs
  end

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

  def publishable?
    if self.published
      return self.valid?
    else
      self.published = true
      result = self.valid?
      self.published = false
      return result
    end
  end

  def prevent_if_published
    if published?
      raise 'published datasets cannot be deleted'
    end
  end

  def status
    if published?
      "Published"
    else
      "Draft"
    end
  end

  def published_dataset_must_have_datafiles_validation
    if self.published && self.links.empty?
      errors.add(:links, "You must add at least one link")
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

  def initialised?
    self.stage == 'initialised'
  end

  def completed?
    self.stage == 'completed'
  end

  def complete!
    self.stage = 'completed'
    self.save!
  end

  private
  def set_initial_stage
    self.stage ||= 'initialised'
  end
end
