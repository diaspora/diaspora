/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function() {

  //edit photo
  $("#edit_photo_toggle").bind('click', function(evt) {
    evt.preventDefault();
    $("#photo_edit_options").toggle();
    $(".edit_photo input:text").first().focus();
  });

  $('.edit_photo').bind('ajax:loading', function(data, json, xhr) {
    $("#photo_edit_options").toggle();
    $("#photo_spinner").show();
    $("#show_photo").find("img").fadeTo(200,0.3);
  });

  $('.edit_photo').bind('ajax:failure', function(data, json, xhr) {
    Diaspora.widgets.alert.alert("Failed to delete photo.", "Are you sure you own this?");
    $("#show_photo").find("img").fadeTo(200,1);
    $("#photo_spinner").hide();
  });

  $('.edit_photo').bind('ajax:success', function(data, json, xhr) {
    json = $.parseJSON(json);
    $(".edit_photo input:text").val(json.photo.caption);
    $("#caption").html(json.photo.caption);
    $("#show_photo").find("img").fadeTo(200,1);
    $("#photo_spinner").hide();
  });

  // make profile photo
  $('.make_profile_photo').bind('ajax:loading', function(data, json, xhr) {
    var person_id = $(this).closest(".photo_options").attr('data-actor_person');

    $("img[data-person_id='" + person_id + "']").fadeTo(200, 0.3);
  });

  $('.make_profile_photo').bind('ajax:success', function(data, json, xhr) {
    json = $.parseJSON(json);

    $("img[data-person_id='" + json.person_id + "']").fadeTo(200, 1).attr('src', json.image_url_small);
  });

  $('.make_profile_photo').bind('ajax:failure', function(data, json, xhr) {
    var person_id = $(this).closest(".photo_options").attr('data-actor_person');
    Diaspora.widgets.alert.alert("Failed to update profile photo!");
    $("img[data-person_id='" + person_id + "']").fadeTo(200, 1);
  });

  // right/left hotkeys
  $(document).keyup(function(e){
    //left
    if(e.keyCode == 37) {
      if( $("#photo_show_left").length > 0 ){
        document.location = $("#photo_show_left").attr('href');
      }

    //right
    } else if(e.keyCode == 39) {
      if( $("#photo_show_right").length > 0 ){
        document.location = $("#photo_show_right").attr('href');
      }
    }
  });

});
