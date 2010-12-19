/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).ready(function() {
  var List = {
    initialize: function() {
      $(".contact_list_search").keyup(function(e) {
        var search = $(this);
        var list   = $(this).siblings("ul").first();
        var query  = new RegExp(search.val(),'i');

        $("li", list).each( function() {
          var element = $(this);
          if( !element.text().match(query) ) {
            if( !element.hasClass('invis') ) {
              element.addClass('invis').fadeOut(100);
            }
          } else {
            element.removeClass('invis').fadeIn(100);
          }
        });
      });
    }
  };

  $('.added').live('ajax:loading', function() {
    $(this).fadeTo(200,0.4);
  });

  $('.added').live('ajax:success', function(data, json, xhr) {
    var json = $.parseJSON(json);
    var contactPictures = $(".contact_pictures");

    if( contactPictures.length > 0 ) {
      if( contactPictures[0].childElementCount == 0 ) {
        $("#no_contacts").fadeIn(200);
      }
    }

    $(".aspect_badge[guid='" + json.aspect_id + "']", ".aspects").remove();
    $(this).parent().html(json.button_html);
    $(this).fadeTo(200,1);
  });

  $('.added').live('ajax:failure', function(data, html, xhr) {
    alert("#{t('.cannot_remove')}");
    $(this).fadeTo(200,1);
  });

  $('.add').live('ajax:loading', function() {
    $(this).fadeTo(200,0.4);
  });

  $('.add').live('ajax:success', function(data, json, xhr) {
    var json = $.parseJSON(json);
    if( $("#no_contacts").is(':visible') ) {
      $("#no_contacts").fadeOut(200);
    }

    $(".badges").prepend(json['badge_html']);
    $(this).parent().html(json['button_html']);
    $(this).fadeTo(200,1);
  });

  $('.added').live('mouseover', function() {
    $(this).addClass("remove");
    $(this).children("img").attr("src","/images/icons/monotone_close_exit_delete.png");
  }).live('mouseout', function() {
    $(this).removeClass("remove");
    $(this).children("img").attr("src","/images/icons/monotone_check_yes.png");
  });

  List.initialize();
});
