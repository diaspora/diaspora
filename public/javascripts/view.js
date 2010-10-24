/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).ready(function(){

	$('#debug_info').click(function() {
		$('#debug_more').toggle('fast');
	});

  $("label").inFieldLabels();

  $('#flash_notice, #flash_error, #flash_alert').animate({
    top: 0
  }).delay(4000).animate({
    top: -100 
  }, $(this).remove());

  $("div.image_cycle").cycle({
    fx: 'fade',
    random: 1,
    timeout: 2000,
    speed: 3000
  });

  //buttons//////
  $(".add_aspect_button").fancybox({ 'titleShow' : false , 'hideOnOverlayClick' : false });
  $("#add_request_button").fancybox({ 'titleShow': false , 'hideOnOverlayClick' : false });
  $(".invite_user_button").fancybox({ 'titleShow': false , 'hideOnOverlayClick' : false });
  $(".add_request_button").fancybox({ 'titleShow': false , 'hideOnOverlayClick' : false });
  $(".remove_person_button").fancybox({ 'titleShow': false , 'hideOnOverlayClick' : false });
  $(".question_mark").fancybox({ 'titleShow': false , 'hideOnOverlayClick' : false });

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

  $("#publisher").find("textarea").keydown( function(e) {
    if (e.keyCode == 13) {
      $(this).closest("form").submit();
    }
  });

  $("#stream").delegate("textarea.comment_box", "keydown", function(e){
    if (e.keyCode == 13) {
      $(this).closest("form").submit();
    }
  });

  $("#user_menu").click( function(){
    $(this).toggleClass("active");
  });

  $('body').click( function(event){
    if(!$(event.target).closest('#user_menu').length){
      $("#user_menu").removeClass("active");
    };
    if(!$(event.target).closest('.reshare_box').length){
      $(".reshare_button").removeClass("active");
      $(".reshare_box").hide();
    };
  });

  $("img", "#left_pane").tipsy({live:true});
  $(".add_aspect_button", "#aspect_nav").tipsy({gravity:'w'});

});//end document ready


//Called with $(selector).clearForm()
$.fn.clearForm = function() {
  return this.each(function() {
  var type = this.type, tag = this.tagName.toLowerCase();
  if (tag == 'form')
    return $(':input',this).clearForm();
  if (type == 'text' || type == 'password' || tag == 'textarea')
    this.value = '';
  else if (type == 'checkbox' || type == 'radio')
    this.checked = false;
  else if (tag == 'select')
    this.selectedIndex = -1;
  $(this).blur();
  });
};

var video_active_container = null;

function openVideo(type, videoid, link) {
  var container = document.createElement('div');
  if(type == 'youtube.com') {
    container.innerHTML = '<a href="http://www.youtube.com/watch?v='+videoid+'" target="_blank">Watch this video on Youtube</a><br><object width="640" height="385"><param name="movie" value="http://www.youtube.com/v/'+videoid+'?fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/'+videoid+'?fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="640" height="385"></embed></object>';
  } else {
    container.innerHTML = 'Invalid videotype <i>'+type+'</i> (ID: '+videoid+')';
  }
  if(video_active_container != null) {
    video_active_container.parentNode.removeChild(video_active_container);
  }
  video_active_container = container;
  $(container).hide();
  link.parentNode.insertBefore(container, this.nextSibling);
  $(container).slideDown('fast', function() { });
  link.onclick = function() { $(container).slideToggle('fast', function() { } ); }
}

$(".make_profile_photo").live("click", function(){
  var user_id   = $(this).closest(".controls").attr('data-actor');
      person_id = $(this).closest(".controls").attr('data-actor_person');
      photo_url = $(this).closest(".controls").attr('data-image_url');

  $.ajax({
    type: "PUT",
    url: '/users/'+user_id,
    data: {"user":{"profile":{ "image_url": photo_url }}},
    success: function(){
      $("img[data-person_id='"+ person_id +"']").each( function() {
        $(this).attr('src', photo_url);
      });
    }
  });
});

