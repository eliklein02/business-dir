class AddIsStationaryToBusinessModel < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :is_stationary, :boolean, default: false
  end
end
