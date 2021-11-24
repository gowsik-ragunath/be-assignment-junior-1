$(document).on('turbolinks:load', function(){
    $(document).on("click", "#expenseSave", (e) => {
        $("#add_expense").click();
    })
});