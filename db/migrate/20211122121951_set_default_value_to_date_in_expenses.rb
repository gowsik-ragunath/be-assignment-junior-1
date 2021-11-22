class SetDefaultValueToDateInExpenses < ActiveRecord::Migration[6.1]
  def up
    change_column :expenses, :date, :timestamp, default: -> { 'CURRENT_TIMESTAMP' }
  end

  def down
    change_column :expenses, :date, :timestamp
  end
end
