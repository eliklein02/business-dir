class RemoveClicksFromBusiness < ActiveRecord::Migration[7.2]
  def change
    remove_column :businesses, :clicks, :int
  end
end
