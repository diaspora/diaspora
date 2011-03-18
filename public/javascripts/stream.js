/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  initialize: function() {
    var $stream = $(".stream");
    var $publisher = $("#publisher");

    Diaspora.widgets.timeago.updateTimeAgo();
    $stream.not(".show").delegate("a.show_post_comments", "click", Stream.toggleComments);
    //audio linx
    //
    Stream.setUpAudioLinks();
    Stream.setUpImageLinks();

    // comment link form focus
    $stream.delegate(".focus_comment_textarea", "click", function(e){
      Stream.focusNewComment($(this), e);
    });

    $stream.delegate("textarea.comment_box", "focus", function(evt) {
      var commentBox = $(this);
      commentBox
        .attr('rows',2)
        .parent().parent()
          .addClass('open');
    });

    $stream.delegate("textarea.comment_box", "blur", function(evt) {
      var commentBox = $(this);
      if (!commentBox.val()) {
        commentBox
          .attr('rows',1)
          .css('height','1.4em')
          .parent().parent()
            .removeClass('open');
      }
    });

    // reshare button action
    $stream.delegate(".reshare_button", "click", function(evt) {
      evt.preventDefault();
      var button = $(this);
      var box = button.siblings(".reshare_box");
      if (box.length > 0) {
        button.toggleClass("active");
        box.toggle();
      }
    });

    $(".new_status_message").live('ajax:loading', function(data, json, xhr) {
      $("#photodropzone").find('li').remove();
      $("#publisher textarea").removeClass("with_attachments").css('paddingBottom', '');
    });

    $(".new_status_message").live('ajax:success', function(data, json, xhr) {
      WebSocketReceiver.addPostToStream(json.post_id, json.html);
      //collapse publisher
      Publisher.close();
      Publisher.clear();
      Stream.setUpImageLinks();
      Stream.setUpAudioLinks();
    });

    $(".new_status_message").bind('ajax:failure', function(data, html , xhr) {
      json = $.parseJSON(html.response);
      if(json.errors.length != 0){
        Diaspora.widgets.alert.alert(json.errors);
      }else{
        Diaspora.widgets.alert.alert('Failed to post message!');
      }
    });

    $(".new_comment").live('ajax:success', function(data, json, xhr) {
      json = $.parseJSON(json);
      WebSocketReceiver.processComment(json.post_id, json.comment_id, json.html, false);
    });
    $(".new_comment").live('ajax:failure', function(data, html, xhr) {
      Diaspora.widgets.alert.alert('Failed to post message!');
    });

    $(".stream").find(".delete").live('ajax:success', function(data, html, xhr) {
      $(this).parents(".stream_element").hide('blind', { direction: 'vertical' }, 300);
    });
  },

  setUpAudioLinks: function(){
    $(".stream a[target='_blank']").each(function(){
      var link = $(this);
      if(link.attr('href').match(/\.mp3$|\.ogg$/)) {
        link.parent().append("<audio preload='none' src='" + this.href + "' controls='controls'>mom</audio>");
        link.remove();
      }
    });
  },

  setUpImageLinks: function(){
    $(".stream a[target='_blank']").each(function(){
      var link = $(this);
      if(link.attr('href').match(/\.gif$|\.jpg$|\.png$|\.jpeg$/)) {
        link.parent().append("<img src='" + this.href + "'</img>");
        link.remove();
      }
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
