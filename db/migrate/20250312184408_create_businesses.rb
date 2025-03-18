class CreateBusinesses < ActiveRecord::Migration[7.2]
  def change
    create_table :businesses do |t|
      t.timestamps
      t.string :name
      t.string :city
      t.string :business_type
      t.float :rating
      t.string :zip_code
      t.string :phone_number
    end
  end
end
