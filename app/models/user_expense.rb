class UserExpense < ApplicationRecord
  # Attribute

  attr_accessor :skip_record_creation


  # Associations
  
  belongs_to :user
  belongs_to :expense

  # Validation
  validates_uniqueness_of :user_id, scope: :expense_id

  # Callbacks

  before_create :set_owed_amount

  private

    def set_owed_amount
      user_expenses_count = self.expense.user_expenses.size 
      return if self.expense.user_expenses.size <= 0 
      self.owed_amount = self.expense.amount / user_expenses_count
    end
end
