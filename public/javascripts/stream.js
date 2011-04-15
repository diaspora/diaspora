/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  initialize: function() {
    var $stream = $(".stream");

    $(".status_message_delete").tipsy({trigger: 'hover', gravity: 'n'});

    Diaspora.widgets.subscribe("stream/reloaded", Stream.initialized);
    Diaspora.widgets.timeago.updateTimeAgo();
    Diaspora.widgets.directionDetector.updateBinds();


    $stream.not(".show").delegate("a.show_post_comments", "click", Stream.toggleComments);
    //audio linx
    Stream.setUpAudioLinks();
    //Stream.setUpImageLinks();

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

    // like/dislike
    $stream.delegate("a.expand_likes", "click", function(evt) {
      evt.preventDefault();
      $(this).siblings('.likes_list').fadeToggle('fast');
    });

    $stream.delegate("a.expand_dislikes", "click", function(evt) {
      evt.preventDefault();
      $(this).siblings('.dislikes_list').fadeToggle('fast');
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
      //Stream.setUpImageLinks();
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

    $(".stream").find(".comment_delete", ".comment").live('ajax:success', function(data, html, xhr) {
      var element = $(this),
          target = element.parents(".comment"),
          post = element.closest('.stream_element'),
          toggler = post.find('.show_post_comments');

      target.hide('blind', { direction: 'vertical' }, 300, function(){
        $(this).remove();
        toggler.html(
          toggler.html().replace(/\d+/,$('.comments', post).find('li').length -1)
        );
      });

    });
  },
  setUpLikes: function(){
    var likes = $("#main_stream .like_it, #main_stream .dislike_it");

    likes.live('ajax:loading', function(data, json, xhr) {
      $(this).parent().fadeOut('fast');
    });

    likes.live('ajax:success', function(data, json, xhr) {
      $(this).parent().detach();
      json = $.parseJSON(json);
      WebSocketReceiver.processLike(json.post_id, json.html);
    });

    likes.live('ajax:failure', function(data, html, xhr) {
      Diaspora.widgets.alert.alert('Failed to like/dislike!');
      $(this).parent().fadeIn('fast');
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
