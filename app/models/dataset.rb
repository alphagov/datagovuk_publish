class Dataset < ApplicationRecord
  belongs_to :organisation
  has_many :datafiles

  validates :title, presence: true
  validates :summary, presence: true

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
