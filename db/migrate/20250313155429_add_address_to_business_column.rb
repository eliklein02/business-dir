class AddAddressToBusinessColumn < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :address, :string
  end
end
