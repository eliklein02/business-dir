class AddBusinessTypeToBusinesses < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :business_type, :string
  end
end
