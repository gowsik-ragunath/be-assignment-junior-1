$(document).on('turbolinks:load', function() {
  $("#addExpense").click(addUser);
})

function addUser() {
  $("#addExpense").unbind("click");
  
  $("a[data-form-prepend]").click(function(e) {

    var obj = $($(this).attr("data-form-prepend"));
    var index = parseInt($(this).attr("data-form-index"));
    var expense_split = $("#expense_split").is(':checked');
    
    for(let temp_object of obj) {
      showExpenseElements(expense_split, obj);
      removeSelectedOption(obj);

      var object_name = $(temp_object).attr("name");

      if(object_name !== undefined && object_name !== null) {
        var replaced_object_name = $(temp_object).attr("name").replace("new_record", index)
        $(temp_object).attr("name", replaced_object_name);
      }
    }

    obj.find("input, select, textarea").each(function(element) {
      
      $(this).attr("name", function() {
        return $(this).attr("name").replace("new_record", index);
      });

    });

    $(this).attr("data-form-index", index + 1);
    obj.insertBefore(this);

    return false;
  });
}

function showExpenseElements(expense_split, temp_object) {
  var unequalAmount = $(temp_object).find(".unequal_amount");

  if(expense_split && unequalAmount) { 
    $(unequalAmount).addClass("disable");
  } else {
    $(unequalAmount).removeClass("disable");
  }
}

function removeSelectedOption(temp_object) {
  var selected_options = $(".user_select").map( function() {
    return $(this).val();
  })

  var selectElement = $(temp_object).find('select');

  $(selectElement).find('option').each( function(option) {
    if($.inArray($(this).val(), selected_options) > -1) {
      $(this).remove();
    }
    
  })
}