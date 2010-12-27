/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  initialize: function() {
    var $stream = $(".stream");
    var $publisher = $("#publisher");

    $stream.not(".show").delegate("a.show_post_comments", "click", Stream.toggleComments);

    // publisher textarea reset
    $publisher.find("textarea").bind("blur", function(){
      $(this).css('height','42px');
    });

    // comment link form focus
    $stream.delegate(".focus_comment_textarea", "click", function(e){
      Stream.focusNewComment($(this), e);
    });

    // comment submit action
    $stream.delegate("textarea.comment_box", "keydown", function(e){
      if (e.keyCode === 13) {
        if(!e.shiftKey) {
          $(this).closest("form").submit();
        }
      }
    });

    $stream.delegate("textarea.comment_box", "focus", function(evt) {
      var commentBox = $(this);
      commentBox
        .attr('rows',2)
        .addClass('force_open')
        .closest("li").find(".submit_instructions").removeClass('hidden');
    });

    $stream.delegate("textarea.comment_box", "blur", function(evt) {
      var commentBox = $(this);
      if (!commentBox.val()) {
        commentBox
          .attr('rows',1)
          .removeClass('force_open')
          .css('height','1.4em')
          .closest("li").find(".submit_instructions").addClass('hidden');
      }
    });

    // reshare button action
    $stream.delegate(".reshare_button", "click", function(evt) {
      evt.preventDefault();
      button = $(this)
      box = button.siblings(".reshare_box");
      if (box.length > 0) {
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

      if ($videoContainer.length > 0) {
        $videoContainer.slideUp('fast', function () {
          $videoContainer.detach();
        });
        return;
      }

      if ($("div.video-container").length > 0) {
        $("div.video-container").slideUp("fast", function() {
          $(this).detach();
        });
      }

      if ($this.data("host") === "youtube.com") {
        $container.html(
          '<a href="//www.youtube.com/watch?v=' + $this.data("video-id") + '" target="_blank">Watch this video on Youtube</a><br />' +
            '<iframe class="youtube-player" type="text/html" src="http://www.youtube.com/embed/' + $this.data("video-id") + '"></iframe>'
          );
      } else if($this.data("host") === "vimeo.com"){
        $container.html(
            '<p><a href="http://vimeo.com/' + $this.data("video-id") + '">Watch this video on Vimeo</a></p>' +
            '<iframe class="vimeo-player" src="http://player.vimeo.com/video/' + $this.data("video-id") + '"></iframe>'
            );
      } else {
        $container.html('Invalid videotype <i>' + $this.data("host") + '</i> (ID: ' + $this.data("video-id") + ')');
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

    $(".new_status_message").bind('ajax:loading', function(data, json, xhr) {
      $("#photodropzone").find('li').remove();
      $("#publisher textarea").removeClass("with_attachments");
    });

    $(".new_status_message").bind('ajax:success', function(data, json, xhr) {
      json = $.parseJSON(json);
      WebSocketReceiver.addPostToStream(json['post_id'], json['html']);
      //collapse publisher
      $("#publisher").addClass("closed");
      $("#photodropzone").find('li').remove();
      $("#publisher textarea").removeClass("with_attachments");
    });
    $(".new_status_message").bind('ajax:failure', function(data, html, xhr) {
      alert('failed to post message!');
    });

    $(".new_comment").live('ajax:success', function(data, json, xhr) {
      json = $.parseJSON(json);
      WebSocketReceiver.processComment(json['post_id'], json['comment_id'], json['html'], false);
    });
    $(".new_comment").live('ajax:failure', function(data, html, xhr) {
      alert('failed to post message!');
    });

    $(".stream").find(".delete").live('ajax:success', function(data, html, xhr) {
      $(this).parents(".message").fadeOut(150);
    });

  },

  toggleComments: function(evt) {
    evt.preventDefault();
    var $this = $(this),
      text = $this.html(),
      showUl = $(this).closest('li'),
      commentBlock = $this.closest("li.message").find("ul.comments", ".content"),
      commentBlockMore = $this.closest("li.message").find(".older_comments", ".content"),
      show = (text.indexOf("show") != -1);

    if( commentBlockMore.hasClass("inactive") ) {
      commentBlockMore.fadeIn(150, function(){
        commentBlockMore.removeClass("inactive");
        commentBlockMore.removeClass("hidden");
      });
    } else {
      if(commentBlock.hasClass("hidden")) {
        commentBlock.removeClass('hidden');
        showUl.css('margin-bottom','-1em');
      }else{
        commentBlock.addClass('hidden');
        showUl.css('margin-bottom','1em');
      }
    }

    $this.html(text.replace((show) ? "show" : "hide", (show) ? "hide" : "show"));
  },

  focusNewComment: function(toggle, evt) {
    evt.preventDefault();
    var commentBlock = toggle.closest("li.message").find("ul.comments", ".content");

    if(commentBlock.hasClass('hidden')) {
      commentBlock.removeClass('hidden');
      commentBlock.find('textarea').focus();
    } else {
      if(!(commentBlock.children().length > 1)){
        commentBlock.addClass('hidden');
      } else {
        commentBlock.find('textarea').focus();
      }
    }
  }
};

$(document).ready(Stream.initialize);
