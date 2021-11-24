$(document).on('turbolinks:load', function(){
    $(document).on("click", ".remove-element", (e) => {
        var closest_expense_field = $(e.target).closest(".user_expense_field");

        closest_expense_field.remove();
    })
});