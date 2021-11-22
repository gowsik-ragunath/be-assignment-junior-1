class Expense < ApplicationRecord

  # Attribute Accessor
  attr_accessor :split

  # Associations
  belongs_to :user
  has_many :user_expenses, dependent: :destroy
  has_many :users, through: :user_expenses

  # Validation callback
  before_validation :reject_repeating_user_expenses

  # Validation
  validate :reject_repeating_user_expenses
  validate :owed_amount_sums_up

  # Rich text
  has_rich_text :description

  # Nested Atributes
  accepts_nested_attributes_for :user_expenses, allow_destroy: true

  private

    def reject_repeating_user_expenses
      user_expenses_user_ids = user_expenses.collect(&:user_id)
      user_expense_visited = []

      self.user_expenses.each do |user_expense|
        if user_expense_visited.include?(user_expense.user_id)
          errors.add(:user_expense, "User has been added more than once in the expense")
        else
          user_expense_visited << user_expense.user_id

          false
        end        
      end
    end

    def owed_amount_sums_up
      if self.split != "1"
        owned_amount_sum = self.user_expenses.collect(&:owed_amount).compact.sum
        
        unless owned_amount_sum == self.amount
          errors.add(:amount, "The total of everyone's owed shares ($#{owned_amount_sum}) is different than the total cost ($#{self.amount - owned_amount_sum})")
        end 
        
      end
    end
end
