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

  after_create_commit :create_friend, if: :can_add_as_friend?
  after_create_commit :update_user_owed_paid_amount

  private

    # Boolean methods

    def expense_split?
      self.expense.equal_split?
    end

    def can_add_as_friend?
      self.add_as_friend && !friend_exists?
    end

    def friend_exists?
      return true if self.expense.user_id == self.user.id

      self.expense.user.friendships.exists?(friend_id: self.user.id)
    end

    def current_user_paid_expense?
      self.expense.payer_id == self.user.id
    end


    # Callback methods

    def set_owed_amount
      # `equal_split_amount` will have max value at the last position
      # Used pop to get the max item first

      split_amount = self.expense.equal_split_amount.pop

      if current_user_paid_expense?
        self.paid_amount = split_amount
      else
        self.owed_amount = split_amount
      end
    end

    def create_friend
      # Add user in expense as a friend
      self.expense.user.friendships.create!(friend_id: self.user.id)
    end

    def update_user_owed_paid_amount
      # Update the paid and owed amount field in user record
      if current_user_paid_expense?
        if expense_split?
          unpaid_amount = self.expense.amount.to_f - self.paid_amount.to_f
          self.user.lent_amount = unpaid_amount
        else
          self.user.lent_amount = self.expense.user_expenses.collect(&:owed_amount).compact.sum
        end
      else
        self.user.owed_amount += self.owed_amount.to_f
        self.user.lent_amount += self.paid_amount.to_f
      end

      self.user.save
    end
end
