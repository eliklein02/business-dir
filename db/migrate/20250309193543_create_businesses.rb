class CreateBusinesses < ActiveRecord::Migration[7.2]
  def change
    create_table :businesses do |t|
      t.timestamps
      t.string :name
      t.string :zip_code
    end
  end
end
