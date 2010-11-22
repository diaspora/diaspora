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

  //buttons//////
  $(".add_aspect_button," + 
    ".manage_aspect_contacts_button," +
    ".invite_user_button," +
    ".add_photo_button," +
    ".remove_person_button," +
    ".question_mark").fancybox({ 'titleShow': false , 'hideOnOverlayClick' : false });

  $("input[type='submit']").addClass("button");

  $(".image_cycle img").load( function() {
    $(this).fadeIn("slow");
  });

  $("#q").focus(
    function() {
      $(this).addClass('active');
    }
  );

  $('.new_request').submit(function(){
    var foo = $(this).parent();
    $(this).hide();
    foo.find('.message').removeClass('hidden');
  });


  $("#q").blur(
    function() {
      $(this).removeClass('active');
    }
  );

  $("#publisher").find("textarea").keydown( function(e) {
    if (e.keyCode === 13) {
      $(this).closest("form").submit();
    }
  });

  $(".stream").delegate("textarea.comment_box", "keydown", function(e){
    if (e.keyCode === 13) {
      $(this).closest("form").submit();
    }
  });

  $("#user_menu").click( function(){
    $(this).toggleClass("active");
  });

  $('body').click( function(event){
    var target = $(event.target);
    if(!target.closest('#user_menu').length){
      $("#user_menu").removeClass("active");
    };
    if(!target.closest('.reshare_pane').length){
      $(".reshare_button").removeClass("active");
      $(".reshare_box").hide();
    };
  });

  $("img", "#left_pane").tipsy({live:true});
  $(".add_aspect_button", "#aspect_nav").tipsy({gravity:'w'});
  $(".person img", ".dropzone").tipsy({live:true});
  $(".avatar", ".aspects").tipsy({live:true});

  $('.webfinger_form').submit(function(evt){
    form = $(evt.currentTarget);
    form.siblings('.spinner').show();
     $('#request_result li:first').hide();
  });

  // hotkeys
  $(window).bind('keyup', 'ctrl+f', function(){
    $("#q").focus();
  });

  $(window).bind('keyup', 'ctrl+e', function(){
    EditPane.toggle();
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
  else if (type == 'checkbox' || type == 'radio')
    this.checked = false;
  else if (tag == 'select')
    this.selectedIndex = -1;
  else if (this.name == 'photos[]')
    this.value = '';
  $(this).blur();
  });
};

var video_active_container = null;

function openVideo(type, videoid, link) {
  var container = document.createElement('div'),
      $container = $(container);
  if(type == 'youtube.com') {
    $container.html('<a href="//www.youtube.com/watch?v='+videoid+'" target="_blank">Watch this video on Youtube</a><br><object width="640" height="385"><param name="movie" value="http://www.youtube.com/v/'+videoid+'?fs=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/'+videoid+'?fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="640" height="385"></embed></object>');
  } else {
    $container.html('Invalid videotype <i>'+type+'</i> (ID: '+videoid+')');
  }
  if(video_active_container != null) {
    video_active_container.parentNode.removeChild(video_active_container);
  }
  video_active_container = container;
  $container.hide();
  link.parentNode.insertBefore(container, this.nextSibling);
  $container.slideDown('fast', function() { });
  link.onclick = function() { $container.slideToggle('fast', function() { } ); }
  
  
}

$(".make_profile_photo").live("click", function(evt){

  evt.preventDefault();

  var $this = $(this),
      $controls = $this.closest(".photo_options"),
      user_id   = $controls.attr('data-actor');
      person_id = $controls.attr('data-actor_person');
      photo_url = $controls.attr('data-image_url');

  $("img[data-person_id='"+ person_id +"']").each( function() {
    $(this).fadeTo(200,0.3);
  });

  $.ajax({
    type: "PUT",
    url: '/people/'+user_id,
    data: {"person":{"profile":{ "image_url": photo_url }}},
    success: function(){
      $("img[data-person_id='"+ person_id +"']").each( function() {
        $(this).fadeTo(200,1);
        this.src = photo_url;
      });
    }
  });
});

$(".getting_started_box").live("click",function(evt){
  $(this).animate({
    left: parseInt($(this).css('left'),30) == 0 ?
        -$(this).outerWidth() :
        0
    },function(evt){ $(this).css('left', '1000px')});
});

