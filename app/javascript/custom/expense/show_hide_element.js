$(document).on('turbolinks:load', function(){
    console.log($("#user_pay_to"))
    $("#user_pay_to").click(function(e) {
        var selectedPayer = $(this).val();

        if(selectedPayer) {
            let description = $(`#settleUpModal #user_expense_${selectedPayer}`);

            $("#settleUpModal .split_up").each(function() {
                $(this).addClass("disable");
            })

            description.removeClass("disable");
        }
    })
});