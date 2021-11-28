class UsersController < ApplicationController
    before_action :set_user

    def settle_up
      current_user.pay_to = user_params[:pay_to].to_i
      current_user.amount = user_params[:amount].to_f

      respond_to do |format|
        if current_user.settle_up_expense
          format.js
        else
          format.js
        end
      end
    end

    private

      def user_params
        params.require(:user).permit(
          :pay_to,
          :amount
        )
      end

        def set_user
            @user = User.find_by(id: params[:id])
        end
end
