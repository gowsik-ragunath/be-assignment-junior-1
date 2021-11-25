class StaticController < ApplicationController
  before_action :set_user, only: :person
  before_action :set_expense
  before_action :set_friends
  
  def dashboard
  end

  def person
  end

  private

    def set_user
      @user = User.includes(user_expenses: { expense: :payer }).find_by(id: params[:id])
    end

    def set_expense
      @expense = Expense.new
    end

    def set_friends
      @friends = current_user.friends
    end
end
