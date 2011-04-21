/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

var List = {
  initialize: function() {
    $(".contact_list_search").live("keyup", function(e) {
      var search = $(this);
      var list   = $(this).siblings("ul").first();
      var query  = new RegExp(search.val(),'i');

      $("> li", list).each( function() {
        var element = $(this);
        if( !element.text().match(query) ) {
          if( !element.hasClass('hidden') ) {
            element.addClass('hidden');
          }
        } else {
          element.removeClass('hidden');
        }
      });
    });
  },
  disconnectUser: function(contact_id){
        $.ajax({
            url: "/contacts/" + contact_id,
            type: "DELETE",
            success: function(){
                if( $('.contact_list').length == 1){
                  $('.contact_list li[data-contact_id='+contact_id+']').fadeOut(200);
                } else if($('#aspects_list').length == 1) {
                  $.facebox.close();
                };
              }
            });
  }
};

$(document).ready(function() {

  $('.added').live('ajax:loading', function() {
    $(this).fadeTo(200,0.4);
  });

  $('.added').live('ajax:success', function(data, jsonString, xhr) {
    var json = $.parseJSON(jsonString);
    var contactPictures = $(".contact_pictures");

    if( contactPictures.length > 0 ) {
      if( contactPictures[0].childElementCount === 0 ) {
        $("#no_contacts").fadeIn(200);
      }
    }

    $(".aspect_badge[guid='" + json.aspect_id + "']", ".aspects").remove();
    $(this).parent().html(json.button_html);
    $(this).fadeTo(200,1);
  });

  $('.added').live('ajax:failure', function(data, html, xhr) {
    if(confirm(Diaspora.widgets.i18n.t('shared.contact_list.cannot_remove'))){
      var contact_id;

      if( $('.contact_list').length == 1){
        contact_id = $(this).parents('li').attr("data-contact_id");
        $('.contact_list li[data-contact_id='+contact_id+']').fadeOut(200);
      } else if($('#aspects_list').length == 1) {
        contact_id = $(this).parents('#aspects_list').attr("data-contact_id");
      };

      List.disconnectUser(contact_id);
    };
    $(this).fadeTo(200,1);
  });


  $('.add').live('ajax:loading', function() {
    $(this).fadeTo(200,0.4);
  });

  $('.add').live('ajax:success', function(data, jsonString, xhr) {
    var json = $.parseJSON(jsonString);
    if( $("#no_contacts").is(':visible') ) {
      $("#no_contacts").fadeOut(200);
    }

    $(".badges").prepend(json.badge_html);
    $(this).parent().html(json.button_html);

    if($('#aspects_list').length == 1) {
      $('.aspect_list').attr('data-contact_id', json.contact_id);
      $('.aspect_list ul').find('.add').each(function(a,b){
        $(b).attr('href', $(b).attr('href').replace('contacts','aspect_memberships'));
      });
    }

    $(this).fadeTo(200,1);
  });

  $('.added').live('mouseover', function() {
    $(this).addClass("remove");
    $(this).children("img").attr("src","/images/icons/monotone_close_exit_delete.png");
  }).live('mouseout', function() {
    $(this).removeClass("remove");
    $(this).children("img").attr("src","/images/icons/monotone_check_yes.png");
  });

  $('.new_aspect').live('ajax:success', function(data, jsonString, xhr){
      var json = JSON.parse(jsonString);
      $('#aspects_list ul').append(json.html);
      $("#aspects_list ul li[data-guid='" + json.aspect_id + "'] .add.button").click();
      });

  List.initialize();
});
