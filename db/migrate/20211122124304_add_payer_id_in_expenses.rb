class AddPayerIdInExpenses < ActiveRecord::Migration[6.1]
  def change
    add_column :expenses, :payer_id, :integer, references: "users"
  end
end
