class AddPwDigestToBusiness < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :password_digest, :string
  end
end
