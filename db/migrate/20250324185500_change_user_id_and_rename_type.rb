class ChangeUserIdAndRenameType < ActiveRecord::Migration[7.2]
  def change
    remove_column :events, :user_id
    remove_column :events, :type
    add_column :events, :event_type, :integer
    add_column :events, :business_id, :integer
  end
end
