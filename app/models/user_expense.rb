class UserExpense < ApplicationRecord
  # Attribute Accessor
  attr_accessor :add_as_friend

  # Associations
  belongs_to :user
  belongs_to :expense

  # Validation
  validates_uniqueness_of :user_id, scope: :expense_id

  # Callbacks
  before_create :set_owed_amount, if: :expense_split?

  after_create_commit :create_friend, if: :can_add_as_friend

  private

    # Conditions
    def can_add_as_friend
      self.add_as_friend.present? && self.add_as_friend
    end

    def expense_split?
      self.expense.split.present? && self.expense.split == "1"
    end

    # Callback methods
    def set_owed_amount
      user_expenses_count = self.expense.user_expenses.size 
      return if self.expense.user_expenses.size <= 0 
      
      self.owed_amount = self.expense.amount / user_expenses_count
    end

    def create_friend
      # Add user in expense as a friend
      unless self.expense.user.friendships.exists?(friend_id: self.user.id)
        self.expense.user.friendships.create!(friend_id: self.user.id)
      end
    end
end
