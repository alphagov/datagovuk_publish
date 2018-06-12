require 'elasticsearch/model'
require 'securerandom'

class Dataset < ApplicationRecord
  enum status: { draft: 0, published: 1 }

  include Elasticsearch::Model

  index_name ENV['ES_INDEX'] || "datasets-#{Rails.env}"
  document_type "dataset"

  after_initialize :set_uuid
  before_save :set_name

  belongs_to :organisation
  belongs_to :topic, optional: true

  has_many :datafiles, dependent: :destroy
  has_many :docs, dependent: :destroy
  has_many :links, dependent: :destroy
  has_one :inspire_dataset, dependent: :destroy

  validate :sluggable_title
  validates :summary, presence: true
  validates :frequency, presence: { message: 'Please indicate how often this dataset is updated' }, on: :dataset_frequency_form
  validates :licence_code, presence: { message: 'Please select a licence for your dataset' }, on: :dataset_licence_form
  validates :topic, presence: { message: 'Please choose a topic' }, on: :dataset_topic_form

  scope :owned_by, ->(creator_id) { where(creator_id: creator_id) }
  scope :published, -> { where(status: "published") }
  scope :with_datafiles, -> { joins(:datafiles) }
  scope :with_no_datafiles, -> { left_outer_joins(:datafiles).where(links: { id: nil }) }

  def publish
    published!
    __elasticsearch__.index_document(id: uuid)
  end

  def unpublish
    return unless published?
    __elasticsearch__.delete_document(id: uuid)
  end

  def as_indexed_json(_options = {})
    as_json(methods: %i[
              public_updated_at
              released
            ],
            include: {
              organisation: {},
              topic: {},
              datafiles: {},
              docs: {},
              inspire_dataset: {}
            })
  end

  def creator
    User.find(id: self.creator_id)
  end

  def creator=(user)
    self.creator_id = user.id
  end

  def set_uuid
    if self.uuid.blank?
      self.uuid = SecureRandom.uuid
    end
  end

  def set_name
    self.name = title.parameterize
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

  def public_updated_at
    most_recently_updated_datafile_timestamp || self.updated_at
  end

  def released
    links.count.positive?
  end

private

  def sluggable_title
    if title.to_s.parameterize.blank?
      errors.add(:title, 'Please enter a valid title')
    end
  end

  def most_recently_updated_datafile_timestamp
    timestamps = self.datafiles.map(&:updated_at)
    timestamps.sort.last if timestamps.present?
  end
end
