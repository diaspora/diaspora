  $(document).ready( function() {

    $("#publisher_content_pickers .status_message").click(function(){
      if( $("#new_status_message").css("display") == "none" ) {
        $("#publisher_content_pickers").children("a").children("li").removeClass("selected");
        $("#publisher_form form").fadeOut(50);

        $(this).children("a > li").toggleClass("selected");
        $("#new_status_message").delay(50).fadeIn(200);
      }
    });

    $("#publisher_content_pickers  .bookmark").click(function(){
      if( $("#new_bookmark").css("display") == "none" ) {
        $("#publisher_content_pickers").children("a").children("li").removeClass("selected");
        $("#publisher_form form").fadeOut(50);

        $(this).children("li").toggleClass("selected");
        $("#new_bookmark").delay(50).fadeIn(200);
      }
    });

    $("#publisher_content_pickers  .blog").click(function(){
      if( $("#new_blog").css("display") == "none" ) {
        $("#publisher_content_pickers").children("a").children("li").removeClass("selected");
        $("#publisher_form form").fadeOut(50);

        $(this).children("li").toggleClass("selected");
        $("#new_blog").delay(50).fadeIn(200);
      }
    });

  });
