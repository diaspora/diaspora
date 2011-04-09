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

  $('.add').live('ajax:loading', function() {
    $(this).fadeTo(200,0.4);
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


  $('.added').live('mouseover', function() {
    $(this).addClass("remove");
    $(this).children("img").attr("src","/images/icons/monotone_close_exit_delete.png");
  }).live('mouseout', function() {
    $(this).removeClass("remove");
    $(this).children("img").attr("src","/images/icons/monotone_check_yes.png");
  });

  List.initialize();
});
