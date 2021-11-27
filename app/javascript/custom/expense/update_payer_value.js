$(document).on('turbolinks:load', function() {
    $("#expense_payer_id").change( function(){
        var firstSelect = $("#expenseModal .user_expense_field select:first");

        if($(firstSelect).length > 0) {
            firstSelect.val($(this).val());
        }
    });
});