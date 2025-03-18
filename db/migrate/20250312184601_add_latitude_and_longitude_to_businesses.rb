class AddLatitudeAndLongitudeToBusinesses < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :latitude, :float
    add_column :businesses, :longitude, :float
  end
end
