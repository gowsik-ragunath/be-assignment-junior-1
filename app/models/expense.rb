class Expense < ApplicationRecord

  # Attribute Accessor
  attr_accessor :split

  # Associations
  belongs_to :user
  belongs_to :payer, class_name: "User", foreign_key: :payer_id
  has_many :user_expenses, dependent: :destroy
  has_many :users, through: :user_expenses

  # Rich text
  has_rich_text :description
  
  # Validation
  validates :amount, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0, less_than: 1000000 }
  validate :reject_repeating_user_expenses
  validate :owed_amount_sums_up

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
      if self.split != "1" && self.amount.present?
        owned_amount_sum = self.user_expenses.collect(&:owed_amount).compact.sum
        paid_amount_sum = self.user_expenses.collect(&:paid_amount).compact.sum

        pending_amount = self.amount - paid_amount_sum
        
        unless pending_amount == owned_amount_sum
          errors.add(:amount, "The total of everyone's owed shares ($#{owned_amount_sum}) is different than the total cost ($#{pending_amount})")
        end 
        
      end
    end
end
