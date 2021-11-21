class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.decimal :amount
      t.timestamp :date
      t.references :user, null: false, foreign_key: true
      t.integer :type

      t.timestamps
    end
  end
end
