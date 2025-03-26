class RemoveEncryptedPasswordFromBusiness < ActiveRecord::Migration[7.2]
  def change
    if column_exists? :businesses, :encrypted_password
      remove_column :businesses, :encrypted_password
    end
    if column_exists? :businesses, :reset_password_token
      remove_column :businesses, :reset_password_token
    end
    if column_exists? :businesses, :remember_created_at
      remove_column :businesses, :remember_created_at
    end
    if column_exists? :businesses, :reset_password_sent_at
      remove_column :businesses, :reset_password_sent_at
    end
    if column_exists? :businesses, :email
      remove_column :businesses, :email
    end
  end
end
