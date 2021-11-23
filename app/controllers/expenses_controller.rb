class ExpensesController < ApplicationController
	# Get /expenses
	def new
	end

	# Post /expenses
	def create
		@expense = current_user.expenses.create!(expense_params)

		redirect_to root_url
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
