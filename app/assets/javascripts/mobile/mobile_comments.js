/*
 *  Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  Diaspora.Mobile = {};
  Diaspora.Mobile.Comments = {
    initialize: function() {
      var self = this;
      $(".stream").on("tap click", "a.back_to_stream_element_top", function() {
        var bottomBar = $(this).closest(".bottom_bar").first();
        var streamElement = bottomBar.parent();
        $("html, body").animate({
          scrollTop: streamElement.offset().top - 54
        }, 1000);
      });

      $(".stream").on("tap click", "a.show_comments", function(evt){
        evt.preventDefault();
        self.toggleComments($(this));
      });

      $(".stream").on("tap click", "a.comment-action", function(evt) {
        evt.preventDefault();
        self.showCommentBox($(this));
        var bottomBar = $(this).closest(".bottom_bar").first();
        var commentContainer = bottomBar.find(".comment_container").first();
        self.scrollToOffset(commentContainer);
      });

      $(".stream").on("submit", ".new_comment", this.submitComment);
    },

    submitComment: function(evt) {
      evt.preventDefault();
      var form = $(this);
      var commentBox = form.find(".comment_box");
      var commentText = $.trim(commentBox.val());
      if (commentText) {
        $.post(form.attr("action")+"?format=mobile", form.serialize(), function(data) {
          Diaspora.Mobile.Comments.updateStream(form, data);
        }, "html");
        return true;
      }
      else {
        commentBox.focus();
        return false;
      }
    },

    toggleComments: function(toggleReactionsLink) {
      if(toggleReactionsLink.hasClass("loading")) { return; }
      if (toggleReactionsLink.hasClass("active")) {
        this.hideComments(toggleReactionsLink);
      } else {
        this.showComments(toggleReactionsLink);
      }
    },

    hideComments: function(toggleReactionsLink) {
      var bottomBar = toggleReactionsLink.closest(".bottom_bar").first(),
          commentsContainer = this.commentsContainerLazy(bottomBar),
          existingCommentsContainer = commentsContainer();
      existingCommentsContainer.hide();
      toggleReactionsLink.removeClass("active");
    },

    showComments: function(toggleReactionsLink) {
      var bottomBar = toggleReactionsLink.closest(".bottom_bar").first(),
          commentsContainer = this.commentsContainerLazy(bottomBar),
          existingCommentsContainer = commentsContainer(),
          commentActionLink = bottomBar.find("a.comment-action");
      if (existingCommentsContainer.length > 0) {
        this.showLoadedComments(toggleReactionsLink, existingCommentsContainer, commentActionLink);
      } else {
        this.showUnloadedComments(toggleReactionsLink, bottomBar, commentActionLink);
      }
    },

    showLoadedComments: function(toggleReactionsLink, existingCommentsContainer, commentActionLink) {
      toggleReactionsLink.addClass("active");
      existingCommentsContainer.show();
      this.showCommentBox(commentActionLink);
      existingCommentsContainer.find("time.timeago").timeago();
    },

    showUnloadedComments: function(toggleReactionsLink, bottomBar, commentActionLink) {
      toggleReactionsLink.addClass("loading");
      var commentsContainer = this.commentsContainerLazy(bottomBar);
      var self = this;
      $.ajax({
        url: toggleReactionsLink.attr("href"),
        success: function (data) {
          toggleReactionsLink.addClass("active").removeClass("loading");
          $(data).insertAfter(bottomBar.children(".show_comments").first());
          self.showCommentBox(commentActionLink);
          commentsContainer().find("time.timeago").timeago();
        },
        error: function() {
          toggleReactionsLink.removeClass("loading");
        }
      });
    },

    commentsContainerLazy: function(bottomBar) {
      return function() {
        return bottomBar.find(".comment_container").first();
      };
    },

    scrollToOffset: function(commentsContainer){
      var commentCount = commentsContainer.find("li.comment").length;
      if ( commentCount > 3 ) {
        var lastComment = commentsContainer.find("li:nth-child("+(commentCount-3)+")");
        $("html,body").animate({
          scrollTop: lastComment.offset().top
        }, 1000);
      }
    },

    showCommentBox: function(link){
      if(!link.hasClass("inactive") || link.hasClass("loading")) { return; }
      var self = this;
      $.ajax({
        url: link.attr("href"),
        beforeSend: function(){
          link.addClass("loading");
        },
        context: link,
        success: function(data) {
          self.appendCommentBox.call(this, link, data);
        },
        error: function() {
          link.removeClass("loading");
        }
      });
    },

    appendCommentBox: function(link, data) {
      link.removeClass("loading");
      link.removeClass("inactive");
      var bottomBar = link.closest(".bottom_bar").first();
      bottomBar.append(data);
      var textArea = bottomBar.find("textarea.comment_box").first()[0];
      autosize(textArea);
    },

    updateStream: function(form, data) {
      var bottomBar = form.closest(".bottom_bar").first();
      this.addNewComments(bottomBar, data);
      this.updateCommentCount(bottomBar);
      this.updateReactionCount(bottomBar);
      this.handleCommentShowing(form, bottomBar);
      bottomBar.find("time.timeago").timeago();
    },

    addNewComments: function(bottomBar, data) {
      if ($(".comment_container", bottomBar).length === 0) {
        $(".show_comments", bottomBar).after($("<div/>", {"class": "comment_container"}));
        $(".comment_container", bottomBar).append($("<ul/>", {"class": "comments"}));
      }
      $(".comment_container .comments", bottomBar).append(data);
    },

    // Fix for no comments
    updateCommentCount: function(bottomBar) {
      var commentCount = bottomBar.find(".comment_count");
      commentCount.text(commentCount.text().replace(/(\d+)/, function (match) {
        return parseInt(match) + 1;
      }));
    },

    // Fix for no reactions
    updateReactionCount: function(bottomBar) {
      var toggleReactionsLink = bottomBar.find(".show_comments").first();
      toggleReactionsLink.text(toggleReactionsLink.text().replace(/(\d+)/, function (match) {
        return parseInt(match) + 1;
      }));
    },

    handleCommentShowing: function(form, bottomBar) {
      var formContainer = form.parent();
      formContainer.remove();
      var commentActionLink = bottomBar.find("a.comment-action").first();
      commentActionLink.addClass("inactive");
      var toggleReactionsLink = bottomBar.find(".show_comments").first();
      this.showComments(toggleReactionsLink);
    }
  };
})();

$(document).ready(function() {
  Diaspora.Mobile.Comments.initialize();
});
