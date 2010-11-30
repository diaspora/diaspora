/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/


$(document).ready(function(){
  var $stream = $(".stream");
  var $publisher = $("#publisher");

  // comment toggle action
  $stream.not(".show").delegate("a.show_post_comments", "click", function(evt) {
    evt.preventDefault();
    var $this = $(this),
      text = $this.html(),
      commentBlock = $this.closest("li").find("ul.comments", ".content"),
      show = (text.indexOf("show") != -1);

    commentBlock.fadeToggle(150, function(){
      commentBlock.toggleClass("hidden");
    });
    $this.html(text.replace((show) ? "show" : "hide", (show) ? "hide" : "show"));
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
      container = document.createElement("div"),
      $container = $(container).attr("class", "video-container"),
      $videoContainer = $this.parent().siblings("div.video-container");

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

    if($this.data("host") === "youtube.com") {
      $container.html(
        '<a href="//www.youtube.com/watch?v=' + $this.data("video-id") + '" target="_blank">Watch this video on Youtube</a><br />' +
        '<iframe class="youtube-player" type="text/html" src="http://www.youtube.com/embed/' + $this.data("video-id")+ '"></iframe>'
      );
    } else {
      $container.html('Invalid videotype <i>'+$this.data("host")+'</i> (ID: '+$this.data("video-id")+')');
    }
 
    $container.hide()
      .insertAfter($this.parent())
      .slideDown('fast');

    $this.click(function() {
      $container.slideUp('fast', function() {
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

});
