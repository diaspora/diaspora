  $(document).ready( function() {

    $("#publisher_content_pickers .status_message").click( selectPicker);

    $("#publisher_content_pickers  .bookmark").click(selectPicker);

    $("#publisher_content_pickers  .blog").click(selectPicker);
    
    function selectPicker(event){
      event.preventDefault();
      if( $("#new_" + this.className).css("display") == "none" ) {
        $("#publisher_content_pickers .selected").removeClass("selected");
        $("#publisher_form form").fadeOut(50);

        $(this).children("a > li").toggleClass("selected");
        $("#new_" + this.className).delay(50).fadeIn(200);
      }

    }
  });
