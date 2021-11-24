$(document).on('turbolinks:load', function(){
    $("a[data-form-prepend]").click(function(e) {

      var obj = $($(this).attr("data-form-prepend"));
      var index = parseInt($(this).attr("data-form-index"));
      var expense_split = $("#expense_split").is(':checked');
      
      for(let temp_object of obj) {
        showExpenseElements(expense_split, temp_object);

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
  })

  function showExpenseElements(expense_split, temp_object) {
    if(expense_split && $(temp_object).hasClass("unequal_amount")) {
      $(temp_object).addClass("disable");
    } else {
      $(temp_object).removeClass("disable");
    }
  }