$(document).on('turbolinks:load', function(){
    $("#expense_split").click(function(e) {
        let unequalAmountElements = $(".unequal_amount");

        if ($(this).is(':checked')) {
            for(let unequalAmountElement of unequalAmountElements) {
                $(unequalAmountElement).addClass("disable");
            }
        } else {

            for(let unequalAmountElement of unequalAmountElements) {
                $(unequalAmountElement).removeClass("disable");
            }
        }
    });
})