class AddContactUrlToBusinessColumn < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :contact_url, :string
  end
end
