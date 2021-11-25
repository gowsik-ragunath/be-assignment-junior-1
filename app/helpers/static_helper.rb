module StaticHelper
    def total_balance
        current_user.owed_amount - current_user.lent_amount
    end

    def total_balance
        total_balance = current_user.total_balance
        dollar_string(total_balance)
    end

    def total_owe
        dollar_string(current_user.owed_amount)
    end

    def total_due_to_me
        dollar_string(current_user.lent_amount)
    end

    def dollar_string(amount)
        if amount > 0
            "+ $#{amount.abs}"
        elsif amount == 0
            "$#{amount.abs}"
        else
            "- $#{amount.abs}"
        end
    end
end
