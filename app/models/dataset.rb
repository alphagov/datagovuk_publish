require 'elasticsearch/model'
require 'securerandom'

class Dataset < ApplicationRecord
  enum status: { draft: 0, published: 1 }

  include Elasticsearch::Model

  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"
  document_type "dataset"

  after_initialize :set_uuid

  before_save :set_name
  before_destroy :prevent_if_published

  belongs_to :organisation
  belongs_to :topic, optional: true
  belongs_to :secondary_topic, optional: true

  has_many :datafiles, dependent: :destroy
  has_many :docs, dependent: :destroy
  has_one :inspire_dataset, dependent: :destroy

  validates :frequency, inclusion: { in: %w(daily monthly quarterly annually financial-year never irregular) },
    allow_nil: true # To allow creation before setting this value
  validate :sluggable_title
  validates :summary, presence: true
  validates :frequency, presence: true, if: :published?
  validates :licence, presence: true, if: :published?
  validates :licence_other, presence: true, if: lambda { licence == 'other' }

  validate  :is_readonly?, on: :update

  scope :owned_by, ->(creator_id) { where(creator_id: creator_id) }
  scope :published, -> { where(status: "published") }
  scope :with_datafiles, -> { joins(:datafiles) }
  scope :with_no_datafiles, -> { left_outer_joins(:datafiles).where(links: { id: nil }) }
  scope :draft, -> { where(status: "draft") }

  def is_readonly?
    if persisted? && self.harvested?
      errors[:base] << 'Harvested datasets cannot be modified.'
    end
  end

  def links
    datafiles + docs
  end

  def publish!
    if publishable?
      transaction do
        set_timestamps
        self.published!
        send_to_search_index
      end
    end
  end

  # What we actually want to index in Elastic, rather than the whole
  # dataset.
  def as_indexed_json(_options = {})
    as_json(
      only: %i[
                name
                legacy_name
                title
                summary
                description
                foi_name
                foi_email
                foi_phone
                foi_web
                contact_name
                contact_email
                contact_phone
                location1
                location2
                location3
                licence
                licence_other
                licence_code
                licence_title
                licence_url
                licence_custom
                frequency
                published_date
                last_updated_at
                created_at
                harvested
                uuid
            ],
      include: {
        organisation: {},
        topic: {},
        datafiles: {},
        docs: {},
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
      self.valid?
    else
      self.status = "published"
      result = self.valid?
      self.status = "draft"
      result
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

  def timeseries?
    %w[annually quarterly monthly].include?(frequency)
  end

private

  def send_to_search_index
    PublishingWorker.perform_async(self.id)
  end

  def sluggable_title
    if title.to_s.parameterize.blank?
      errors.add(:title, 'Please enter a valid title')
    end
  end

  def set_timestamps
    set_first_publication_date
    set_last_updated_date
  end

  def set_first_publication_date
    self.published_date ||= Time.now
  end

  def set_last_updated_date
    self.last_updated_at = Time.now
  end
end
