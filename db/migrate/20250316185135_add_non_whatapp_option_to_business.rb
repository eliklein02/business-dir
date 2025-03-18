class AddNonWhatappOptionToBusiness < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :communication_form, :integer
  end
end
