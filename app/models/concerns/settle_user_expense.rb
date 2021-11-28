module SettleUserExpense
  extend ActiveSupport::Concern

  def settle_up_expense
    return false unless amount_pay_to_present?
    return false unless amount_valid?
    return false unless payer_present?

    payer_expense_ids = get_payer_expense_ids[pay_to]

    if payer_expense_ids.present?
      # Get all user expenses owed to this payer
      owed_user_expenses = cache_owed_user_expenses.where(expense_id: payer_expense_ids)

      paid_amount = amount
      pending_amount = amount

      # Loop through user expense that can be paid 
      p owed_user_expenses
      owed_user_expenses.each do |user_expense|
        if user_expense.owed_amount > pending_amount
          user_expense.owed_amount = user_expense.owed_amount - pending_amount
          pending_amount = 0
        else
          pending_amount = amount - user_expense.owed_amount
          user_expense.owed_amount = 0
        end

        user_expense.save

        break if pending_amount <= 0
      end

      if pending_amount > 0
        self.addition_amount = pending_amount
      end
    end

    true
  end


  # Validation

  def amount_pay_to_present?
    # amount and pay_to attr_accessor must be present
    if amount.present? && pay_to.present?
      true
    else
      self.errors.add(:invalid, "Please pass amount and payer")

      false
    end
  end

  def amount_valid?
    # amount must be greater than 0
    if amount > 0.to_f
      true
    else
      self.errors.add(:amount, "Please enter an amount greater than 0")

      false
    end
  end

  def payer_present?
    # User must be owed some amount from this pay_to user
    if expense_paid_users.exists?(id: pay_to)
      true
    else
      self.errors.add(:pay_to, "Payer not present")
      
      false
    end
  end
end