class ExpensesController < ApplicationController
	# Get /expenses
	def new
	end

	# Post /expenses
	def create
		@expense = current_user.expenses.new(expense_params)

		respond_to do |format|
			if @expense.save
				@new_expense = Expense.new

				format.html { redirect_to root_url }
				# As most of the element in dashboard need to be render
				# Reload the page instead of updating elements in JS(in this case entier page)
				format.js { redirect_to root_url }
			else
				format.js
			end
		end
	end

	# Get /expenses/:id
	def edit
	end

	# Patch /expenses/:id
	def update
	end

	# Delete /expenses/:id
	def destroy
	end

	private

		def expense_params
			params.require(:expense).permit(
				:amount, 
				:date,
				:description,
				:payer_id,
				:split,
				user_expenses_attributes: [
					:user_id,
					:owed_amount,
					:paid_amount,
					:add_as_friend
				]
			)
		end
end
