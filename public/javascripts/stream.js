/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Stream = {
  selector: "#main_stream",

  initialize: function() {
    Diaspora.widgets.timeago.updateTimeAgo();
    Diaspora.widgets.directionDetector.updateBinds();

    $(".status_message_delete").tipsy({
      trigger: "hover",
      gravity: "n"
    });

    $("a.show_post_comments:not(.show)", this.selector).click(Stream.toggleComments);

    //audio links
    Stream.setUpAudioLinks();
    //Stream.setUpImageLinks();

    // comment link form focus
    $(".focus_comment_textarea", this.selector).click(function(evt) {
      Stream.focusNewComment($(this), evt);
    });

    $("textarea.comment_box", this.selector).bind("focus blur", function(evt) {
      var commentBox = $(this);
      commentBox
        .attr("rows", (evt.type === "focus") ? 2 : 1)
        .parent().parent()
          .toggleClass("open");
    });

    $("a.expand_likes", this.selector).click(function(evt) {
      evt.preventDefault();
      $(this).siblings(".likes_list").fadeToggle("fast");
    });

    $("a.expand_dislikes", this.selector).click(function(evt) {
      evt.preventDefault();
      $(this).siblings(".dislikes_list").fadeToggle("fast");
    });

    // reshare button action
    $(".reshare_button", this.selector).click(function(evt) {
      evt.preventDefault();
      var button = $(this),
        box = button.siblings(".reshare_box");

      if (box.length > 0) {
        button.toggleClass("active");
        box.toggle();
      }
    });

    $(".new_comment", this.selector).bind("ajax:failure", function() {
      Diaspora.widgets.alert.alert(Diaspora.widgets.i18n.t("failed_to_post_message"));
    });

    $(".comment .comment_delete", this.selector).bind("ajax:success", function() {
      var element = $(this),
        target = element.parents(".comment"),
        post = element.closest(".stream_element"),
        toggler = post.find(".show_post_comments");

      target.hide("blind", { direction: "vertical" }, 300, function() {
        $(this).remove();
        toggler.html(
          toggler.html().replace(/\d+/, $(".comments li", post).length - 1)
        );
      });

    });

    // collapse long comments
    $(".content p", this.selector).expander({
      slicePoint: 400,
      widow: 12,
      expandText: Diaspora.widgets.i18n.t("show_more"),
      userCollapse: false
    });
  },

  setUpLikes: function() {
    var likes = $(".like_it, .dislike_it", this.selector);

    likes.bind("ajax:loading", function() {
      $(this).parent().fadeOut("fast");
    });

    likes.bind("ajax:failure", function() {
      Diaspora.widgets.alert.alert(Diaspora.widgets.i18n.t("failed_to_like"));
      $(this).parent().fadeIn("fast");
    });
  },

  setUpAudioLinks: function() {
    $(".stream a[target='_blank']").each(function() {
      var link = $(this);
      if(this.href.match(/\.mp3$|\.ogg$/)) {
        $("<audio/>", {
          preload: "none",
          src: this.href,
          controls: "controls"
        }).appendTo(link.parent());

        link.remove();
      }
    });
  },

  setUpImageLinks: function() {
    $(".stream a[target='_blank']").each(function() {
      var link = $(this);
      if(this.href.match(/\.gif$|\.jpg$|\.png$|\.jpeg$/)) {
        $("<img/>", {
          src: this.href
        }).appendTo(link.parent());

        link.remove();
      }
    });
  },

  toggleComments: function(evt) {
    evt.preventDefault();
    var $this = $(this),
      showUl = $(this).closest("li"),
      commentBlock = $this.closest(".stream_element").find("ul.comments", ".content"),
      commentBlockMore = $this.closest(".stream_element").find(".older_comments", ".content")

    if( commentBlockMore.hasClass("inactive") ) {
      commentBlockMore.fadeIn(150, function() {
        commentBlockMore.removeClass("inactive");
        commentBlockMore.removeClass("hidden");
      });
      $this.html(Diaspora.widgets.i18n.t("comments.hide"));
    } else {
      if(commentBlock.hasClass("hidden")) {
        commentBlock.removeClass("hidden");
        showUl.css("margin-bottom","-1em");
        $this.html(Diaspora.widgets.i18n.t("comments.hide"));
      }else{
        commentBlock.addClass("hidden");
        showUl.css("margin-bottom","1em");
        $this.html(Diaspora.widgets.i18n.t("comments.show"));
      }
    }
  },

  focusNewComment: function(toggle, evt) {
    evt.preventDefault();
    var commentBlock = toggle.closest(".stream_element").find("ul.comments", ".content");

    if(commentBlock.hasClass("hidden")) {
      commentBlock.removeClass("hidden");
      commentBlock.find("textarea").focus();
    } else {
      if(commentBlock.children().length <= 1) {
        commentBlock.addClass("hidden");
      } else {
        commentBlock.find("textarea").focus();
      }
    }
  }
};

$(document).ready(function() {
  if( $(Stream.selector).length == 0 ) { return }
  Diaspora.widgets.subscribe("stream/reloaded", Stream.initialize, Stream);
  Diaspora.widgets.publish("stream/reloaded");
});
