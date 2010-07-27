  $(document).ready( function() {

    $("#publisher_content_pickers .status_message").click(selectPublisherTab);
    $("#publisher_content_pickers .bookmark").click(selectPublisherTab);
    $("#publisher_content_pickers .blog").click(selectPublisherTab);
    $("#publisher_content_pickers .photo").click(selectPublisherTab);
	
	$("#new_status_message").submit(function() {
		var new_status = $('#status_message_message').val() + " - just now";
		$('#latest_message').text( new_status );
	});

    function selectPublisherTab(evt){
      evt.preventDefault();
      var form_id = "#new_" + this.className
      if( $(form_id).css("display") == "none" ) {
        $("#publisher_content_pickers").children("li").removeClass("selected");
        $("#publisher_form form").fadeOut(50);

        $(this).toggleClass("selected");
        $(form_id).delay(50).fadeIn(200);
      }
    }

	function replaceCurrentStatus(evt){
		evt.preventDefault();
		var old_message = $("#latest_message");
		alert(old_message);
		var status = $(".new_status_message");
		alert(status);
	}
  });
