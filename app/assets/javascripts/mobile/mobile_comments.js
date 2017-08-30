/*
 *  Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  Diaspora.Mobile.Comments = {
    stream: function(){ return $(".stream"); },

    initialize: function() {
      var self = this;

      new Diaspora.MarkdownEditor(".comment-box");

      this.stream().on("tap click", "a.show-comments", function(evt){
        evt.preventDefault();
        self.toggleComments($(this));
      });

      this.stream().on("tap click", "a.comment-action", function(evt) {
        evt.preventDefault();
        var bottomBar = $(this).closest(".bottom-bar").first();
        var toggleReactionsLink = bottomBar.find("a.show-comments").first();

        if (toggleReactionsLink.length === 0) {
          self.showCommentBox($(this));
        } else {
          if (toggleReactionsLink.hasClass("loading")) {
            return;
          }
          if (!toggleReactionsLink.hasClass("active")) {
            self.showComments(toggleReactionsLink);
          }
        }
        var commentContainer = bottomBar.find(".comment-container").first();
        self.scrollToOffset(commentContainer);
      });

      this.stream().on("submit", ".new-comment", this.submitComment);
    },

    submitComment: function(evt){
      evt.preventDefault();
      var form = $(this);
      var commentBox = form.find(".comment-box");
      var commentText = $.trim(commentBox.val());
      if(!commentText){
        commentBox.focus();
        return false;
      }

      $.post(form.attr("action") + "?format=mobile", form.serialize(), function(data){
        Diaspora.Mobile.Comments.updateStream(form, data);
      }, "html").fail(function(response) {
        Diaspora.Mobile.Alert.handleAjaxError(response);
        Diaspora.Mobile.Comments.resetCommentBox(form);
      });

      autosize($(".add-comment-switcher:not(.hidden) textarea"));
    },

    toggleComments: function(toggleReactionsLink) {
      if(toggleReactionsLink.hasClass("loading")) { return; }

      if(toggleReactionsLink.hasClass("active")) {
        this.hideComments(toggleReactionsLink);
        toggleReactionsLink.parents(".bottom-bar").find(".add-comment-switcher").addClass("hidden");
      } else {
        this.showComments(toggleReactionsLink);
      }
    },

    hideComments: function(toggleReactionsLink) {
      var bottomBar = toggleReactionsLink.closest(".bottom-bar").first();
      this.bottomBarLazy(bottomBar).deactivate();
      toggleReactionsLink.removeClass("active");
    },

    showComments: function(toggleReactionsLink) {
      var bottomBar = toggleReactionsLink.closest(".bottom-bar").first(),
          bottomBarContainer = this.bottomBarLazy(bottomBar),
          existingCommentsContainer = bottomBarContainer.getCommentsContainer(),
          commentActionLink = bottomBar.find("a.comment-action");

      bottomBarContainer.activate();
      bottomBarContainer.showLoader();

      if (existingCommentsContainer.length > 0) {
        this.showLoadedComments(toggleReactionsLink, existingCommentsContainer, commentActionLink);
        bottomBarContainer.hideLoader();
      } else {
        this.showUnloadedComments(toggleReactionsLink, bottomBar, commentActionLink);
      }
    },

    showLoadedComments: function(toggleReactionsLink, existingCommentsContainer, commentActionLink) {
      this.showCommentBox(commentActionLink);
      existingCommentsContainer.find("time.timeago").timeago();
    },

    showUnloadedComments: function(toggleReactionsLink, bottomBar, commentActionLink) {
      toggleReactionsLink.addClass("loading");
      var bottomBarContainer = this.bottomBarLazy(bottomBar);
      var self = this;
      $.ajax({
        url: toggleReactionsLink.attr("href"),
        success: function (data) {
          toggleReactionsLink.addClass("active").removeClass("loading");
          $(data).insertAfter(bottomBar.children(".show-comments").first());
          self.showCommentBox(commentActionLink);
          bottomBarContainer.getCommentsContainer().find("time.timeago").timeago();
          bottomBarContainer.activate();
        },
        error: function(){
          bottomBarContainer.deactivate();
        }
      }).always(function(){
        toggleReactionsLink.removeClass("loading");
        bottomBarContainer.hideLoader();
      });
    },

    bottomBarLazy: function(bottomBar) {
      return  {
        loader: function(){
          return bottomBar.find(".ajax-loader");
        },

        getCommentsContainer: function(){
          return bottomBar.find(".comment-container").first();
        },

        getShowCommentsLink: function(){
          return bottomBar.find("a.show-comments");
        },

        showLoader: function(){
          this.loader().removeClass("hidden");
        },

        hideLoader: function(){
          this.loader().addClass("hidden");
        },

        activate: function(){
          bottomBar.addClass("active").removeClass("inactive");
          this.getShowCommentsLink().addClass("active");
          this.getShowCommentsLink().find("i").removeClass("entypo-chevron-down").addClass("entypo-chevron-up");
        },

        deactivate: function(){
          bottomBar.removeClass("active").addClass("inactive");
          this.getShowCommentsLink().removeClass("active");
          this.getShowCommentsLink().find("i").addClass("entypo-chevron-down").removeClass("entypo-chevron-up");
        }
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
      var bottomBar = link.closest(".bottom-bar").first();
      var textArea = bottomBar.find("textarea.comment-box").first()[0];
      bottomBar.find(".add-comment-switcher").removeClass("hidden");
      autosize(textArea);
    },

    updateStream: function(form, data) {
      var bottomBar = form.closest(".bottom-bar").first();
      this.addNewComments(bottomBar, data);
      this.updateCommentCount(bottomBar);
      this.increaseReactionCount(bottomBar);
      this.handleCommentShowing(form, bottomBar);
      bottomBar.find("time.timeago").timeago();
    },

    addNewComments: function(bottomBar, data) {
      if ($(".comment-container", bottomBar).length === 0) {
        $(".show-comments", bottomBar).after($("<div/>", {"class": "comment-container"}));
        $(".comment-container", bottomBar).append($("<ul/>", {"class": "comments"}));
      }
      $(".comment-container .comments", bottomBar).append(data);
    },

    // Fix for no comments
    updateCommentCount: function(bottomBar) {
      var commentCount = bottomBar.find(".comment-count");
      commentCount.text(commentCount.text().replace(/(\d+)/, function (match) {
        return parseInt(match, 10) + 1;
      }));
    },

    // Fix for no reactions
    increaseReactionCount: function(bottomBar) {
      var toggleReactionsLink = bottomBar.find(".show-comments").first();
      var count = toggleReactionsLink.text().match(/.*(\d+).*/);
      count = parseInt(count, 10) || 0;
      var text = Diaspora.I18n.t("stream.comments", {count: count + 1});

      // No previous comment
      if (count === 0) {
        var parent = toggleReactionsLink.parent();
        var postGuid = bottomBar.parents(".stream-element").data("guid");

        toggleReactionsLink.remove();
        toggleReactionsLink = $("<a/>", {"class": "show-comments", "href": Routes.postComments(postGuid) + ".mobile"})
          .html(text + "<i class='entypo-chevron-up'/>");
        parent.prepend(toggleReactionsLink);
        bottomBar.removeClass("inactive").addClass("active");
      }
      else {
        toggleReactionsLink.html(text + "<i class='entypo-chevron-up'/>");
      }
    },

    handleCommentShowing: function(form, bottomBar) {
      var formContainer = form.parent();
      formContainer.find("textarea.form-control").first().val("");
      this.resetCommentBox(formContainer);
      var commentActionLink = bottomBar.find("a.comment-action").first();
      commentActionLink.addClass("inactive");
      this.showComments(bottomBar.find(".show-comments").first());
    },

    resetCommentBox: function(el){
      var commentButton = $(el).find("input.comment-button").first();
      commentButton.attr("value", commentButton.data("reset-with"));
      commentButton.removeAttr("disabled");
      commentButton.blur();
    }
  };
})();

$(document).ready(function() {
  Diaspora.Mobile.Comments.initialize();
});
