class Preview < ApplicationRecord
  belongs_to :link, foreign_key: "datafile_id"
end
