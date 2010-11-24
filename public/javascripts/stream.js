/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).ready(function(){
  var $stream = $(".stream");
  var $publisher = $("#publisher");
  // expand all comments on page load
	$stream.not('.show').find('.comments').each(function(index) {
      var comments = $(this);
	    if(comments.children("li").length > 1) {
        var show_comments_toggle = comments.closest("li").find(".show_post_comments");
        expandComments(show_comments_toggle,false);
      }
  });

  // comment toggle action
  $stream.not(".show").delegate("a.show_post_comments", "click", function(evt) {
    evt.preventDefault();
    expandComments($(this),true);
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

  $stream.delegate("textarea.comment_box", "blur", function(evt){
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
  
  $stream.delegate("a.video-link", "click", function(evt) {
    evt.preventDefault();
    
    var $this = $(this),
      container = document.createElement('div'),
      $container = $(container).attr("class", "video-container");

    var $videoContainer = $this.siblings("div.video-container");
    if($videoContainer.length > 0) {
      $videoContainer.slideUp('fast', function () {
        $videoContainer.detach();
      });
      return;
    }
    
    if($("div.video-container").length > 0) {
      $("div.video-container").slideUp("fast", function() { 
        $(this).detach();
      });
    }
      
    if($this.data("host") === 'youtube.com') {
	  	$container.html(
        '<a href="//www.youtube.com/watch?v=' + $this.data("video-id") + '" target="_blank">Watch this video on Youtube</a><br />' +
        '<iframe class="youtube-player" type="text/html" src="http://www.youtube.com/embed/' + $this.data("video-id")+ '"></iframe>'
      );
    } else {
      $container.html('Invalid videotype <i>'+$this.data("host")+'</i> (ID: '+$this.data("video-id")+')');
    }
  
    $container.hide();
    this.parentNode.insertBefore(container, this.nextSibling);
    $container.slideDown('fast');
    
    $this.click(function() {
      $container.slideToggle('fast', function () {
        $(this).detach();
      });
    });  
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


function expandComments(toggler,animate){
  var text         = toggler.html();
      commentBlock = toggler.closest("li").find("ul.comments", ".content");

  if( toggler.hasClass("visible")) {
    toggler.removeClass("visible")
           .html(text.replace("hide", "show"));

    if(animate) {
      commentBlock.fadeOut(150);
    } else {
      commentBlock.hide();
    }

  } else {
    toggler.addClass("visible")
           .html(text.replace("show", "hide"));

    if(animate) {
      commentBlock.fadeIn(150);
    } else {
      commentBlock.show();
    }
  }
}
