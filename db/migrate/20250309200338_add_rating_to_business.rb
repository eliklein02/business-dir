class AddRatingToBusiness < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :rating, :float
  end
end
