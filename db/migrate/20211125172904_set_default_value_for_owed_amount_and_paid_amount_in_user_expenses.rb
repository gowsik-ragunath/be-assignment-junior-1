class SetDefaultValueForOwedAmountAndPaidAmountInUserExpenses < ActiveRecord::Migration[6.1]
  def change
    change_column :user_expenses, :owed_amount, :decimal, default: 0.00, precision: 10, scale: 2
    change_column :user_expenses, :paid_amount, :decimal, default: 0.00, precision: 10, scale: 2
  end
end
