$(document).on('turbolinks:load', function() {
    $("#expense_payer_id").change(updateAndDisableSelect);
});

updateAndDisableSelect = function() {
    var firstSelect = $("#expenseModal .user_expense_field select:first");
    var firstUserExpense = $("#expenseModal .user_expense_field:first");

    if($(firstSelect).length > 0) {
        console.log($("#expense_payer_id").val())
        firstSelect.val($("#expense_payer_id").val());
        $(firstSelect).css('pointer-events','none');

        if($(firstUserExpense).length > 0) {
            var removeElement = $(firstUserExpense).find(".remove-element");

            if(removeElement) {
                $(removeElement).remove();
            }
        }
    }
}