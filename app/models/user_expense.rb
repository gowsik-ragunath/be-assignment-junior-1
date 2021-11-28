class UserExpense < ApplicationRecord
  # Attribute Accessor
  attr_accessor :add_as_friend

  # Associations
  belongs_to :user
  belongs_to :expense

  # Validation
  validates :user, presence: true
  validate :reject_payer_owed_amount, if: :user_paid_expense_has_other_users?
  validate :reject_owed_paid_amount

  # Callbacks
  before_create :set_owed_amount, if: :expense_split?

  after_create_commit :create_friend, if: :can_add_as_friend?
  after_create_commit :update_user_owed_paid_amount
  after_update_commit :update_user_owed_amount, if: -> { p self.owed_amount_previously_changed? }

  # Scopes

  scope :loaned, -> (user_id) { includes(:user).where.not(owed_amount: 0).where.not(user_id: user_id) }
  scope :user_owed, -> (user_id) { includes(:user).where.not(owed_amount: 0).where(user_id: user_id) }
  scope :owed_expenses, -> (user_id) { joins(:expense).includes(expense: :payer).user_owed(user_id).where("expenses.payer_id != ?", user_id) }

  private

    # Boolean methods

    def user_paid_expense_has_other_users?
      more_than_one_user_in_expense? && current_user_paid_expense?
    end

    def more_than_one_user_in_expense?
      self.expense.user_expenses.size > 1
    end

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
      return false if self.user_id.nil?
      
      self.expense.payer_id == self.user.id
    end

    def reject_payer_owed_amount
      if self.owed_amount > 0
        errors.add(:owed_amount, "Payer can't owe any amount")
      end
    end

    def reject_owed_paid_amount
      if (self.owed_amount != 0 && self.paid_amount != 0) && more_than_one_user_in_expense? && !expense_split?
        errors.add(:user, "User can't have both owed and paid amount")
      end
    end

    # Callback methods

    def set_owed_amount
      # `equal_split_amount` will have max value at the last position
      # Used pop to get the max item first

      split_amount = self.expense.equal_split_amount.pop

      if current_user_paid_expense?
        self.paid_amount = split_amount
        self.owed_amount = 0
      else
        self.owed_amount = split_amount
        self.paid_amount = 0
      end
    end

    def create_friend
      # Add user in expense as a friend
      self.expense.user.friendships.create!(friend_id: self.user.id)
    end

    def update_user_owed_paid_amount
      # return when current user is the only user in expense
      return if (current_user_paid_expense? && self.expense.user_expenses.size == 1)

      # Update the paid and owed amount field in user record
      if current_user_paid_expense?
        if expense_split?
          unpaid_amount = self.expense.amount.to_f - self.paid_amount.to_f
          self.user.lent_amount += unpaid_amount
        else
          self.user.lent_amount += self.paid_amount.to_f
        end
      else
        self.user.owed_amount += self.owed_amount.to_f
        self.user.lent_amount += self.paid_amount.to_f
      end

      self.user.save
    end

    def update_user_owed_amount
      old_owed_amount = owed_amount_previously_was.to_f

      # Update current users owed amount
      if self.owed_amount.to_f == 0
        self.user.owed_amount -= old_owed_amount
      else
        self.user.owed_amount -= (old_owed_amount - self.owed_amount.to_f)
      end
  
  
      if self.user.save
        # Update payer lent amount
        payer = self.expense.payer
        return unless payer.present?

        # Reduce the old lent amount and sum the owed amount to get the new lent amount
        payer.lent_amount -= old_owed_amount
        payer.lent_amount += self.owed_amount.to_f

        payer.save
      end
    end
end
