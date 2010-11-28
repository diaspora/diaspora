/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready( function(){
  $("#edit_photo_toggle").bind('click', function(evt) {
    evt.preventDefault();
    $("#photo_edit_options").toggle();
    $(".edit_photo input[type='text']").first().focus();
  });

  $('.edit_photo').bind('ajax:loading', function(data, json, xhr) {
    $("#photo_edit_options").toggle();
    $("#photo_spinner").show();
    $("#show_photo").find("img").fadeTo(200,0.3);
  });

  $('.edit_photo').bind('ajax:failure', function(data, json, xhr) {
    alert('Failed to delete photo.  Are you sure you own this?');
    $("#show_photo").find("img").fadeTo(200,1);
    $("#photo_spinner").hide();
  });
  
  $('.edit_photo').bind('ajax:success', function(data, json, xhr) {
    json = $.parseJSON(json);
    $(".edit_photo input[type='text']").val(json['photo']['caption']);
    $("#caption").html(json['photo']['caption']);
    $("#show_photo").find("img").fadeTo(200,1);
    $("#photo_spinner").hide();
  });
});
