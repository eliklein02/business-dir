class AddFullAddressToBusinessModel < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :full_address, :string
  end
end
