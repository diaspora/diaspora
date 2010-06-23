$(document).ready(function(){  
	$('a').hover(function(){
	  $(this).fadeTo(60, 0.5);
	}, function(){
	  $(this).fadeTo(80, 1);
	});

	$('ul.nav li').hover(function(){
	  $(this).fadeTo(60, 0.5);
	}, function(){
	  $(this).fadeTo(80, 1);
	});

	$('#status_message_message').click(function() {
		$(this).val("")
	});
	
	$('#status_message_submit').click(function() {
		$('#status_message_message').val("");
	});
	
	$('#flash_notice, #flash_error, #flash_alert').delay(1500).slideUp(130);
	
	
	

});//end document ready