class CreateBusinessTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :business_types do |t|
      t.timestamps
      t.string :name
    end
  end
end
