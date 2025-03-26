class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.timestamps
      t.integer :type
    end
  end
end
