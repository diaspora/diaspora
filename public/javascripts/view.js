$(document).ready(function(){
	tinyMCE.init({
			mode : "textareas",
			theme : "advanced",
			plugins : "emotions,spellchecker,advhr,insertdatetime,preview",	

			// Theme options - button# indicated the row# only
		theme_advanced_buttons1 : "newdocument,|,bold,italic,underline,|,justifyleft,justifycenter,justifyright,fontsizeselect,formatselect",
		theme_advanced_buttons2 : "cut,copy,paste|,bullist,numlist,|,outdent,indent|,undo,redo,|,link,unlink,anchor,image,|,preview,|,forecolor,backcolor",
		theme_advanced_buttons3 : "insertdate,inserttime,|,spellchecker,|,sub,sup,|,charmap,emotions",	
		theme_advanced_toolbar_location : "top",
		theme_advanced_toolbar_align : "left",
		//theme_advanced_resizing : true //leave this out as there is an intermittent bug.
	});
	  
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

	$('#status_message_message').click(clearForm);
	
	$('#bookmark_title').click(clearForm);
	
	$('#bookmark_link').click(clearForm);

  function clearForm(){
   $(this).val("");
  }

	$('#debug_info').click(function() {
		$('#debug_more').toggle('fast', function() {
			
		});
	});
	

	
	$('#flash_notice, #flash_error, #flash_alert').delay(1500).slideUp(130);
	
});//end document ready
