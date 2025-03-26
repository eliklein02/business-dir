class RemoveEncryptedPasswordFromBusiness < ActiveRecord::Migration[7.2]
  def change
    remove_column :businesses, :encrypted_password
    remove_column :businesses, :reset_password_token
    remove_column :businesses, :remember_created_at
    remove_column :businesses, :reset_password_sent_at
    remove_column :businesses, :email
  end
end
