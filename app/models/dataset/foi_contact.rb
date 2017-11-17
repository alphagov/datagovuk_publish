class Dataset::FoiContact
  include ActiveModel::Model

  attr_accessor :foi_name, :foi_email, :foi_phone

  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates :foi_name, presence: true
  validates :foi_email, presence: true, format: { with: EMAIL_FORMAT, message: "Please enter a valid email" }
end
