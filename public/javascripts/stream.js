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
    //audio links
    Stream.setUpAudioLinks();
    //Stream.setUpImageLinks();

    // collapse long comments
    $(".content p", this.selector).expander({
      slicePoint: 400,
      widow: 12,
      expandText: Diaspora.widgets.i18n.t("show_more"),
      userCollapse: false
    });
  },

  initializeLives: function(){
    // reshare button action
    $(".reshare_button", this.selector).live("click", function(evt) {
      evt.preventDefault();
      var button = $(this),
        box = button.siblings(".reshare_box");

      if (box.length > 0) {
        button.toggleClass("active");
        box.toggle();
      }
    });

    this.setUpComments();

  },

  setUpComments: function(){
    $("a.show_post_comments:not(.show)", this.selector).live('click', Stream.toggleComments);
    // comment link form focus
    $(".focus_comment_textarea", this.selector).live('click', function(evt) {
      Stream.focusNewComment($(this), evt);
    });

    $(".new_comment", this.selector).live("ajax:failure", function() {
       Diaspora.widgets.alert.alert(Diaspora.widgets.i18n.t("failed_to_post_message"));
    });

    $(".comment .comment_delete", this.selector).live("ajax:success", function() {
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

    $("textarea.comment_box", this.selector).live("focus", function(evt) {
      if (this.value === undefined || this.value ===  ''){
        var commentBox = $(this);
        commentBox
          .parent().parent()
            .addClass("open");
      }
    });
    $("textarea.comment_box", this.selector).live("blur", function(evt) {
      if (this.value === undefined || this.value ===  ''){
        var commentBox = $(this);
        commentBox
          .parent().parent()
            .removeClass("open");
      }
    });
    
  },

  setUpAudioLinks: function() {
    $(".stream a[target='_blank']").each(function(r){
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
  Stream.initializeLives();
  Diaspora.widgets.subscribe("stream/reloaded", Stream.initialize, Stream);
  Diaspora.widgets.publish("stream/reloaded");
});
