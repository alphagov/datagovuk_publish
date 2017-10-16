require 'elasticsearch/model'
require 'securerandom'

class Dataset < ApplicationRecord
  enum status: { draft: 0, published: 1 }

  TITLE_FORMAT = /([a-z]){3}.*/i
  STAGES = %w(initialised completed)

  include Elasticsearch::Model
  extend FriendlyId

  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name
  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"
  document_type "dataset"

  after_initialize :set_initial_stage
  before_destroy :prevent_if_published
  before_save :set_uuid

  belongs_to :organisation
  belongs_to :theme, optional: true
  belongs_to :secondary_theme, optional: true

  has_many :links
  has_many :docs
  has_one :inspire_dataset

  validates :frequency, inclusion: { in: %w(daily weekly monthly quarterly annually financial-year never) },
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
        # Writing to both old and new fields until data has been migrated from :published field to new :status field
        self.update(published: true, status: "published")
        PublishingWorker.perform_async(self.id)
      end
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

  # map the dataset.as_json so that the keys are in a format that ckan recognises
  def ckanify_metadata
    publish_json = self.as_json
    organisation = Organisation.find(publish_json["organisation_id"])
    ckan_json = {
      id: publish_json['uuid'],
      name: publish_json['name'],
      title: publish_json['title'],
      notes: publish_json['summary'],
      description: publish_json['summary'],
      organization: {name: organisation.name},
      update_frequency: convert_freq_to_legacy_format(publish_json['frequency']),
      unpublished: !publish_json['published'],
      metadata_created: publish_json['created_at'],
      metadata_modified: publish_json['last_updated_at'],
      geographic_coverage: [(publish_json['location1'] || "").downcase],
      license_id: publish_json['licence']
    }
    add_custom_freq_key(ckan_json, publish_json)
  end

  def convert_freq_to_legacy_format(frequency)
    { 'annually' => 'annual' ,
      'quarterly' => 'quarterly',
      'monthly' => 'monthly',
      'daily' => 'other',
      'weekly' => 'other',
      'never' => 'never',
      'discontinued' => 'discontinued',
      'one-off' => 'other'
    }.fetch(frequency,"")
  end

  def add_custom_freq_key(ckan_json, publish_json)
    if ['daily', 'weekly', 'one-off'].include? publish_json['frequency']
      ckan_json['update_frequency-other'] = publish_json['frequency']
    end
    ckan_json
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
    self.save!(validate: false)
  end

  private

  def set_initial_stage
    self.stage ||= 'initialised'
  end
end
