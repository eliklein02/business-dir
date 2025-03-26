class ChangeClicksCloumnDefault < ActiveRecord::Migration[7.2]
  def change
    change_column_default :businesses, :clicks, from: nil, to: 0
  end
end
