class ChangeBusinessTypeToEnum < ActiveRecord::Migration[7.2]
  def change
    remove_column :businesses, :business_type
    add_column :businesses, :business_type, :integer
  end
end
