class StaticController < ApplicationController
  before_action :set_user, only: :person
  before_action :set_friends
  
  def dashboard
    @expense = Expense.new

    @user_expense = @expense.user_expenses.build
  end

  def person
  end

  private

    def set_user
      @user = User.find_by(id: params[:id])
    end

    def set_friends
      p @friends = current_user.friends
    end
end
