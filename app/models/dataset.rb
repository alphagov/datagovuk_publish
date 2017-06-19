class Dataset < ApplicationRecord
  extend FriendlyId

  belongs_to :organisation
  has_many :datafiles

  validates :title, presence: true
  validates :summary, presence: true

  friendly_id :slug_candidates, :use => :slugged, :slug_column => :name

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
end
