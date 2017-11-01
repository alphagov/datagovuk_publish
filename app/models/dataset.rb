require 'elasticsearch/model'
require 'securerandom'

class Dataset < ApplicationRecord
  enum status: { draft: 0, published: 1 }

  TITLE_FORMAT = /([a-z]){3}.*/i
  STAGES = %w(initialised completed)

  include Elasticsearch::Model

  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"
  document_type "dataset"

  after_initialize :set_initial_stage, :set_uuid
  before_save :set_name
  before_destroy :prevent_if_published

  belongs_to :organisation
  belongs_to :theme, optional: true
  belongs_to :secondary_theme, optional: true

  has_many :links
  has_many :docs
  has_one :inspire_dataset

  validates :frequency, inclusion: { in: %w(daily monthly quarterly annually financial-year never) },
                        allow_nil: true # To allow creation before setting this value
  validates :title, presence: true, format: { with: TITLE_FORMAT }
  validates :summary, presence: true
  validates :frequency, presence: true, if: :published?
  validates :licence, presence: true, if: :published?
  validates :licence_other, presence: true, if: lambda { licence == 'other' }
  validates :stage, inclusion: { in: STAGES }

  validate  :published_dataset_must_have_datafiles_validation
  validate  :is_readonly?, on: :update

  scope :owned_by, ->(creator_id) { where(creator_id: creator_id) }
  scope :published, ->{ where(status: "published") }

  def is_readonly?
    if persisted? && self.harvested?
      errors[:base] << 'Harvested datasets cannot be modified.'
    end
  end

  def datafiles
    links + docs
  end

  def publish!
    if self.publishable?
      transaction do
        self.published!
        self.last_published_at = Time.now
        PublishingWorker.perform_async(self.id)
      end
    end
  end

def update_legacy
  update_legacy_dataset
  update_legacy_datafiles
end

def update_legacy_dataset
  Legacy::Dataset.new(self).update
end

def update_legacy_datafiles
  datafiles = Datafile.where(dataset_id: self.id)
  datafiles.updated_after(last_published_at).each do |datafile|
    Legacy::Datafile.new(datafile).update
  end
end

  # What we actually want to index in Elastic, rather than the whole
  # dataset.
  def as_indexed_json(_options={})
    as_json(
      only: [:name, :title, :summary, :description,
             :location1, :location2, :location3,
             :licence, :licence_other, :frequency,
             :published_date, :last_updated_at, :created_at,
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

  def publishable?
    if self.published?
      return self.valid?
    else
      self.status = "published"
      result = self.valid?
      self.status = "draft"
      return result
    end
  end

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

  def set_name
    self.name = title.parameterize
  end

  def prevent_if_published
    raise 'published datasets cannot be deleted' if published?
  end

  def published_dataset_must_have_datafiles_validation
    if self.published? && self.links.empty?
      errors.add(:links, "You must add at least one link")
    end
  end

  def daily?
    frequency == 'daily'
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

  def initialised?
    self.stage == 'initialised'
  end

  def completed?
    self.stage == 'completed'
  end

  def complete!
    self.stage = 'completed'
    self.save!(validate: false)
  end

  def timeseries?
    ["annually", "quarterly", "monthly"].include?(frequency)
  end

  private

  def set_initial_stage
    self.stage ||= 'initialised'
  end
end
