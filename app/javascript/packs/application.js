// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import jQuery from 'jquery';
window.$ = jQuery
window.jQuery = jQuery

import 'bootstrap/dist/js/bootstrap'
require("jgrowl")
Rails.start()
Turbolinks.start()
ActiveStorage.start()

require("trix")
require("@rails/actiontext")


$(document).ready(function(){
  $("a[data-form-prepend]").click(function(e) {
    var obj = $($(this).attr("data-form-prepend"));
    var index = parseInt($(this).attr("data-form-index"));
    
    for(let temp_object of obj) {
      var object_name = $(temp_object).attr("name");
      
      if(object_name !== undefined && object_name !== null) {
        var replaced_object_name = $(temp_object).attr("name").replace("new_record", index)
        $(temp_object).attr("name", replaced_object_name);
      }
    }
    obj.find("input, select, textarea").each(function(element) {

      console.log(element)
      $(this).attr("name", function() {

        return $(this).attr("name").replace("new_record", index);

      });

    });

    
    $(this).attr("data-form-index", index + 1);
    obj.insertBefore(this);

    return false;

  });
})