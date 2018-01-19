class RenameTypesInLink < ActiveRecord::Migration[5.1]
  def change
    Link.where(type: 'Link').update_all(type: 'Datafile')
  end
end
