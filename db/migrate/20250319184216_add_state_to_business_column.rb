class AddStateToBusinessColumn < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :state, :string
  end
end
