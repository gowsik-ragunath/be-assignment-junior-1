class StaticController < ApplicationController
  def dashboard
    @expense = Expense.new

    @user_expense = @expense.user_expenses.build
  end

  def person
  end
end
