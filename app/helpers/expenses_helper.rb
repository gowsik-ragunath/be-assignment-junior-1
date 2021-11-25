module ExpensesHelper
    def get_user_id_field_value(local_assigns)
        local_assigns.has_key?(:user_id) ? local_assigns[:user_id] : nil
    end
end
