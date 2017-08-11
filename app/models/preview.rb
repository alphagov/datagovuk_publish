class Preview < ApplicationRecord
  belongs_to :link, foreign_key: "datafiles_id"
end
