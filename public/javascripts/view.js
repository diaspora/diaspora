/*   Copyright 2010 Diaspora Inc.
 *
 *   This file is part of Diaspora.
 *
 *   Diaspora is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Diaspora is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
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

