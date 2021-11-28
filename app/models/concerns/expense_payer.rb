module ExpensePayer
  extend ActiveSupport::Concern

  def expense_paid_users
    # Retruns the users who lent amount to current users
    return @expense_paid_users if defined? @expense_paid_users

    expenses = cache_owed_user_expenses.where(expense_id: payer_expense_ids)

    @expense_paid_users = User.where(id: expenses.pluck(:payer_id))
  end

  def payer_specific_owed_amount
    # Returns a hash that has key as `payer id` and `total owed_amount` as value
    return @payer_specific_owed_amount if @payer_specific_owed_amount

    owed_amount_hash = {}

    get_payer_expense_ids.each do |payer_id, expense_ids|
      owed_amount_hash[payer_id] = cache_owed_user_expenses
                                  .where(expense_id: expense_ids)
                                  .pluck(:owed_amount).sum.to_f
    end

    @payer_specific_owed_amount = owed_amount_hash
  end

  def payer_id_name_hash
    # Returns a hash with `paid user id` as key and `paid user name` as value
    return @payer_id_name_hash if defined? @payer_id_name_hash
    payer_ids = cache_owed_user_expenses.pluck(:payer_id)

    @payer_id_name_hash = expense_paid_users.pluck(:id, :name).to_h
  end

  def get_payer_expense_ids
    # Returns a key-value pairs hash with `payer id` in key and `expense ids` in value
    # E.g., { 12: [123, 32], 13: [234, 43] }

    return @get_payer_expense_ids if defined? @get_payer_expense_ids

    payer_expense_hash = {}

    payer_expense = Expense.where(id: payer_expense_ids).select(:id, :payer_id)
    expense_ids = payer_expense.ids
    payer_ids = payer_expense.map(&:payer_id)
    
    payer_expense.group_by(&:payer_id).each do |payer_id, expense|
      payer_expense_hash[payer_id] = expense.map(&:id)
    end

    @get_payer_expense_ids = payer_expense_hash
  end
end