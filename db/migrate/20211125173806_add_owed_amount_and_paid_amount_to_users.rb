class AddOwedAmountAndPaidAmountToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :owed_amount, :decimal, default: 0.00, precision: 10, scale: 2
    add_column :users, :paid_amount, :decimal, default: 0.00, precision: 10, scale: 2
  end
end
