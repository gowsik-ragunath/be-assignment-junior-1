class RemoveTypeFromExpense < ActiveRecord::Migration[6.1]
  def change
    remove_column :expenses, :type
  end
end
