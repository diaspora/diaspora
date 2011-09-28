/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).bind("mobileinit", function() {
   $.extend($.mobile, {
     ajaxLinksEnabled: false,
     ajaxEnabled: false,
     ajaxFormsEnabled: false

   });
	$.mobile.selectmenu.prototype.options.nativeMenu = false;
});


$(document).ready(function(){
  $(".like_action.inactive").bind('tap', function(evt){
    evt.preventDefault();
    var target = $(this),
        postId = target.data('post-id');

    $.ajax({
      url: '/posts/'+postId+'/likes.json',
      type: 'POST',
      complete: function(data){
        target.addClass('inactive')
              .removeClass('active')
              .data('post-id', postId);
      }
    });
  });

  $(".like_action.active").bind('tap', function(evt){
    evt.preventDefault();
    var target = $(this),
        postId = $(this).data('post-id'),
        likeId = $(this).data('like-id');


    $.ajax({
      url: '/posts/'+postId+'/likes/'+likeId+'.json',
      type: 'DELETE',
      complete: function(data){
        target.addClass('inactive')
              .removeClass('active')
              .data('like-id', '');
      }
    });
  });
});
