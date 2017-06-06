class Task < ApplicationRecord
  belongs_to :organisation

  def self.short_name
    owning_organisation
  end

end
