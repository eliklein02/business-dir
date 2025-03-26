class AddClickToBusinessModel < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :clicks, :int
  end
end
