/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  initialize: function() {
    var $stream = $(".stream");
    var $publisher = $("#publisher");

    $("abbr.timeago").timeago();
    $stream.not(".show").delegate("a.show_post_comments", "click", Stream.toggleComments);

    // publisher textarea reset
    $publisher.find("textarea").bind("focus", function() {
      $(this).css('min-height','42px');
    });
    $publisher.find("form").bind("blur", function() {
      $("#publisher textarea").css('min-height','2px');
    });

    // comment link form focus
    $stream.delegate(".focus_comment_textarea", "click", function(e){
      Stream.focusNewComment($(this), e);
    });

    // comment submit action
    $stream.delegate("textarea.comment_box", "keydown", function(e){
      if (e.keyCode === 13) {
        if(!e.shiftKey) {
          $(this).blur();
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

    // fade in controls
    $stream.delegate(".stream_element", "mouseenter", function(evt) {
      var controls = $(this).find('.controls'),
          badges = $(this).find('.aspect_badges');

      controls.fadeIn(100);
      controls.fadeIn(100);
      badges.fadeTo(100,1);
    });
    $stream.delegate(".stream_element", "mouseleave", function(evt) {
      var controls = $(this).find('.controls'),
          badges = $(this).find('.aspect_badges');

      controls.show()
              .fadeOut(50);
      badges.fadeTo(50,0.5);
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

    $(".new_status_message").live('ajax:loading', function(data, json, xhr) {
      $("#photodropzone").find('li').remove();
      $("#publisher textarea").removeClass("with_attachments");
    });

    $(".new_status_message").live('ajax:success', function(data, json, xhr) {
      json = $.parseJSON(json);
      WebSocketReceiver.addPostToStream(json.post_id, json.html);
      //collapse publisher
      $("#publisher").addClass("closed");
      $("#photodropzone").find('li').remove();
      $("#publisher textarea").removeClass("with_attachments");
    });

    $(".new_status_message").bind('ajax:failure', function(data, html, xhr) {
      Diaspora.widgets.alert.alert('Failed to post message!');
    });

    $(".new_comment").live('ajax:success', function(data, json, xhr) {
      json = $.parseJSON(json);
      WebSocketReceiver.processComment(json.post_id, json.comment_id, json.html, false);
    });
    $(".new_comment").live('ajax:failure', function(data, html, xhr) {
      Diaspora.widgets.alert.alert('Failed to post message!');
    });

    $(".stream").find(".delete").live('ajax:success', function(data, html, xhr) {
      $(this).parents(".status_message").fadeOut(150);
    });
  },

  toggleComments: function(evt) {
    evt.preventDefault();
    var $this = $(this),
      text = $this.html(),
      showUl = $(this).closest('li'),
      commentBlock = $this.closest(".stream_element").find("ul.comments", ".content"),
      commentBlockMore = $this.closest(".stream_element").find(".older_comments", ".content"),
      show = (text.indexOf("show") != -1);

    if( commentBlockMore.hasClass("inactive") ) {
      commentBlockMore.fadeIn(150, function() {
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
    var commentBlock = toggle.closest(".stream_element").find("ul.comments", ".content");

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
