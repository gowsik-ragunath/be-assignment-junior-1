class RenamePaidAmountToLentAmountInUsers < ActiveRecord::Migration[6.1]
  def up
    rename_column :users, :paid_amount, :lent_amount
  end

  def down
    rename_column :users, :lent_amount, :paid_amount
  end
end
