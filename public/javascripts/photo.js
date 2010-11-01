/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).keydown(function(e){
  switch(e.keyCode) {
    case 37:
      if(!$("textarea").hasClass("hasfocus")){//prevent redirect if textarea has focus
        window.location = document.getElementById("prev_photo").href;
      }
      break;
    case 39:
      if(!$("textarea").hasClass("hasfocus")){
        window.location = document.getElementById("next_photo").href;
      }
      break;
  }
});

$(document).ready(function(){
  var $edit_photo = $(".edit_photo");

  //add a clas to verify if a textarea has focus
  $("textarea").live('focus',function(){
    $(this).addClass("hasfocus");
  });
  $("textarea").live('blur',function(){
    $(this).removeClass("hasfocus");
  });

  //show form to add description
  $(".edit-desc").click(function(){
    $(".edit_photo").toggle(); 
  });

  //Add a description with ajax request
  $("#photo_submit").click(function(event){
    event.preventDefault();
    var method = $edit_photo.attr("method");
    var url = $edit_photo.attr("action");
    var data = $edit_photo.serialize();
    $(".description").text(document.getElementById("photo_caption").value);
    $edit_photo.toggle();

      $.ajax({  
        type: method,
        url: url,  
        data: data,  
        success: function(response){  
          $("#add-description").remove();
        }
      });

  });

});

