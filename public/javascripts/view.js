/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3.  See
*   the COPYRIGHT file.
*/


$(document).ready(function(){

	$('#debug_info').click(function() {
		$('#debug_more').toggle('fast');
	});

  $("label").inFieldLabels();

  $('#flash_notice, #flash_error, #flash_alert').delay(2500).slideUp(130);

  $("div.image_cycle").cycle({
    fx: 'fade',
    random: 1,
    timeout: 2000,
    speed: 3000
  });

  //buttons//////
  $("#add_aspect_button").fancybox({ 'titleShow' : false });
  $("#add_request_button").fancybox({ 'titleShow': false });
  $(".add_request_button").fancybox({ 'titleShow': false });

  $("input[type='submit']").addClass("button");

  $(".image_cycle img").load( function() {
    $(this).fadeIn("slow");
  });

  $("#global_search").hover(
    function() {
      $(this).fadeTo('fast', '1');
    },
    function() {
      $(this).fadeTo('fast', '0.5');
    }
  );

  $("#publisher textarea").keydown( function(e) {
    if (e.shiftKey && e.keyCode == 13) {
      $("#publisher form").submit();
    }
  });

});//end document ready


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

