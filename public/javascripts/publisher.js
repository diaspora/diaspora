  $(document).ready( function() {

    $("#publisher_content_pickers .status_message").click(function(){
      if( $("#new_status_message").css("display") == "none" ) {
        $("#publisher_form form").fadeOut(50);
        $("#new_status_message").delay(50).fadeIn(200);
      }
    });

    $("#publisher_content_pickers  .bookmark").click(function(){
      if( $("#new_bookmark").css("display") == "none" ) {
        $("#publisher_form form").fadeOut(50);
        $("#new_bookmark").delay(50).fadeIn(200);
      }
    });

    $("#publisher_content_pickers  .blog").click(function(){
      if( $("#new_blog").css("display") == "none" ) {
        $("#publisher_form form").fadeOut(50);
        $("#new_blog").delay(50).fadeIn(200);
      }
    });

  });
