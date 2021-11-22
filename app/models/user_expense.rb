class UserExpense < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :expense

  # Callbacks
  before_create :set_owed_amount, if: :expense_is_not_split?

  private

    def expense_is_not_split?
      !(self.expense.split.present? && self.expense.split == "1")
    end

    def set_owed_amount
      user_expenses_count = self.expense.user_expenses.size 
      return if self.expense.user_expenses.size <= 0 
      
      self.owed_amount = self.expense.amount / user_expenses_count
    end
end
