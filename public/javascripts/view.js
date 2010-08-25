$(document).ready(function(){
	

	$('#debug_info').click(function() {
		$('#debug_more').toggle('fast', function() {
			
		});
	});
	
  $("label").inFieldLabels();
	
  $('#flash_notice, #flash_error, #flash_alert').delay(2500).slideUp(130);
  
//Called with $(selector).clearForm()
	$.fn.clearForm = function() {
		return this.each(function() {
		var type = this.type, tag = this.tagName.toLowerCase();
		if (tag == 'form')
			return $(':input',this).clearForm();
		if (type == 'text' || type == 'password' || tag == 'textarea')
			this.value = '';
		//else if (type == 'checkbox' || type == 'radio')
			//this.checked = false;
		else if (tag == 'select')
			this.selectedIndex = -1;
		$(this).blur();
    });
	};
  
  $("div.image_cycle").cycle({
    fx: 'fade',
    random: 1,
    timeout: 2000,
    speed: 3000
  });

  //buttons//////
  

  $("#add_album_button").fancybox();
  $("#add_group_button").fancybox();
  $("#add_request_button").fancybox({ 'titleShow': false });
  $("#add_photo_button").fancybox({
    'onClosed'   :   function(){
      if($("#add_photo_button").hasClass("uploading_complete")){
        $("#add_photo_button").removeClass("uploading_complete");
        reset_photo_fancybox();
      }
    }
  });

  //pane_toggler_button("photo");

  $("input[type='submit']").addClass("button");

  $(".image_thumb img").load( function() {
    $(this).fadeIn("slow");
  });

  $(".image_cycle img").load( function() {
    $(this).fadeIn("slow");
  });



});//end document ready

function reset_photo_fancybox(){
        album_id = $(".album_id")[0].id;
        ajax = $.get("/photos/new?album_id=" + album_id, function(){
          $("#new_photo_pane").html(ajax.responseText)
        });
}

function pane_toggler_button( name ) {
  
    $("#add_" + name + "_button").toggle(
    function(evt){
      evt.preventDefault();
      $("#add_" + name + "_pane").fadeIn(300);
    },function(evt){
      evt.preventDefault();
      $("#add_" + name +"_pane").fadeOut(200);
    }
  );
}
