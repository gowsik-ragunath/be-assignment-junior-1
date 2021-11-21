class CreateUserExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :user_expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :expense, null: false, foreign_key: true
      t.timestamp :status
      t.decimal :paid_amount
      t.decimal :owed_amount

      t.timestamps
    end
  end
end
