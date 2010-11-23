/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).ready(function(){
  var $stream = $(".stream");
  var $publisher = $("#publisher");
  // expand all comments on page load
	$(".stream:not('.show')").find('.comments').each(function(index) {
      var comments = $(this);
	    if(comments.children("li").length > 1) {
        var show_comments_toggle = comments.closest("li").find(".show_post_comments");
        expandComments(show_comments_toggle);
      }
  });

  // comment toggle action
  $stream.not(".show").delegate("a.show_post_comments", "click", function(evt) {
    evt.preventDefault();
    expandComments($(this));
  });

  // comment submit action
  $stream.delegate("a.comment_submit", "click", function(evt){
    $(this).closest("form").children(".comment_box").attr("rows", 1);
  });

  $stream.delegate("textarea.comment_box", "focus", function(evt){
    var commentBox = $(this);
    commentBox.attr("rows", 2)
              .closest("form").find(".comment_submit").fadeIn(200);
  });

  $(".stream").delegate("textarea.comment_box", "blur", function(evt){
    var commentBox = $(this);
    if( !commentBox.val() ) {
      commentBox.attr("rows", 1)
                .closest("form").find(".comment_submit").hide();
    }
  });

  // reshare button action
  $stream.delegate(".reshare_button", "click", function(evt){
    evt.preventDefault();
    button = $(this)
    box = button.siblings(".reshare_box");
    if(box.length > 0){
      button.toggleClass("active");
      box.toggle();
    }
  });

  $(".new_status_message").bind('ajax:success', function(data, json, xhr){
    json = $.parseJSON(json); 
    WebSocketReceiver.addPostToStream(json['post_id'],json['html']);
  });
  $(".new_status_message").bind('ajax:failure', function(data, html, xhr){
    alert('failed to post message!');
  });

  $(".new_comment").live('ajax:success', function(data, json, xhr){
    json = $.parseJSON(json); 
    WebSocketReceiver.processComment(json['post_id'],json['comment_id'],json['html'],false);
  });
  $(".new_comment").live('ajax:failure', function(data, html, xhr){
    alert('failed to post message!');
  });

});//end document ready


function expandComments(toggler){
  var text         = toggler.html();
      commentBlock = toggler.closest("li").find("ul.comments", ".content");

  if( toggler.hasClass("visible")) {
    toggler.removeClass("visible")
           .html(text.replace("hide", "show"));
    //commentBlock.slideUp(150);
    commentBlock.hide();

  } else {
    toggler.addClass("visible")
           .html(text.replace("show", "hide"));
    //commentBlock.slideDown(150);
    commentBlock.show();
  }
}
