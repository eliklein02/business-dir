class AddMilePreferenceToBusinessColumn < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :mile_preference, :integer
  end
end
