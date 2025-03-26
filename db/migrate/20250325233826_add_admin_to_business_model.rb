class AddAdminToBusinessModel < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :admin, :boolean, default: false
  end
end
