/*
 *  Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function() {

  $(".stream").on("tap click", "a.back_to_stream_element_top", function() {
    var bottomBar = $(this).closest(".bottom_bar").first();
    var streamElement = bottomBar.parent();
    $("html, body").animate({
      scrollTop: streamElement.offset().top - 54
    }, 1000);
  });

  $(".stream").on("tap click", "a.show_comments", function(evt){
    evt.preventDefault();
    toggleComments($(this));
  });

  function toggleComments(toggleReactionsLink) {
    if (toggleReactionsLink.hasClass("active")) {
      hideComments(toggleReactionsLink);
    } else {
      showComments(toggleReactionsLink);
    }
  }

  function hideComments(toggleReactionsLink) {
    var bottomBar = toggleReactionsLink.closest(".bottom_bar").first(),
        commentsContainer = commentsContainerLazy(bottomBar),
        existingCommentsContainer = commentsContainer();
    existingCommentsContainer.hide();
    toggleReactionsLink.removeClass("active");
  }

  function showComments(toggleReactionsLink) {
    var bottomBar = toggleReactionsLink.closest(".bottom_bar").first(),
        commentsContainer = commentsContainerLazy(bottomBar),
        existingCommentsContainer = commentsContainer(),
        commentActionLink = bottomBar.find("a.comment_action");
    if (existingCommentsContainer.length > 0) {
      showLoadedComments(toggleReactionsLink, existingCommentsContainer, commentActionLink);
    } else {
      showUnloadedComments(toggleReactionsLink, bottomBar, commentActionLink);
    }
  }

  function showLoadedComments(toggleReactionsLink, existingCommentsContainer, commentActionLink) {
    existingCommentsContainer.show();
    showCommentBox(commentActionLink);
    toggleReactionsLink.addClass("active");
    existingCommentsContainer.find("time.timeago").timeago();
  }

  function showUnloadedComments(toggleReactionsLink, bottomBar, commentActionLink) {
    var commentsContainer = commentsContainerLazy(bottomBar);
    $.ajax({
      url: toggleReactionsLink.attr("href"),
      success: function (data) {
        $(data).insertAfter(bottomBar.children(".show_comments").first());
        showCommentBox(commentActionLink);
        toggleReactionsLink.addClass("active");
        commentsContainer().find("time.timeago").timeago();
      }
    });
  }

  function commentsContainerLazy(bottomBar) {
    return function() {
      return bottomBar.find(".comment_container").first();
    };
  }

  $(".stream").on("tap click", "a.comment_action", function(evt) {
    evt.preventDefault();
    showCommentBox(this);
    var bottomBar = $(this).closest(".bottom_bar").first();
    var commentContainer = bottomBar.find(".comment_container").first();
    scrollToOffset(commentContainer);
  });
  var scrollToOffset = function(commentsContainer){
    var commentCount = commentsContainer.find("li.comment").length;
    if ( commentCount > 3 ) {
      var lastComment = commentsContainer.find("li:nth-child("+(commentCount-3)+")");
      $("html,body").animate({
        scrollTop: lastComment.offset().top
      }, 1000);
    }
  };

  function showCommentBox(link){
    var commentActionLink = $(link);
    if(commentActionLink.hasClass("inactive")) {
      $.ajax({
        url: commentActionLink.attr("href"),
        beforeSend: function(){
          commentActionLink.addClass("loading");
        },
        context: commentActionLink,
        success: function(data){
          appendCommentBox.call(this, commentActionLink, data);
        }
      });
    }
  }

  function appendCommentBox(link, data) {
    link.removeClass("loading");
    link.removeClass("inactive");
    var bottomBar = link.closest(".bottom_bar").first();
    bottomBar.append(data);
    var textArea = bottomBar.find("textarea.comment_box").first()[0];
    MBP.autogrow(textArea);
  }

  $(".stream").on("submit", ".new_comment", function(evt) {
    evt.preventDefault();
    var form = $(this);
    $.post(form.attr("action")+"?format=mobile", form.serialize(), function(data) {
      updateStream(form, data);
    }, "html");
  });

  function updateStream(form, data) {
    var bottomBar = form.closest(".bottom_bar").first();
    addNewComments(bottomBar, data);
    updateCommentCount(bottomBar);
    updateReactionCount(bottomBar);
    handleCommentShowing(form, bottomBar);
    bottomBar.find("time.timeago").timeago();
  }

  function addNewComments(bottomBar, data) {
    var commentsContainer = bottomBar.find(".comment_container").first();
    var comments = commentsContainer.find(".comments").first();
    comments.append(data);
  }

  // Fix for no comments
  function updateCommentCount(bottomBar) {
    var commentCount = bottomBar.find(".comment_count");
    commentCount.text(commentCount.text().replace(/(\d+)/, function (match) {
      return parseInt(match) + 1;
    }));
  }

  // Fix for no reactions
  function updateReactionCount(bottomBar) {
    var toggleReactionsLink = bottomBar.find(".show_comments").first();
    toggleReactionsLink.text(toggleReactionsLink.text().replace(/(\d+)/, function (match) {
      return parseInt(match) + 1;
    }));
  }

  function handleCommentShowing(form, bottomBar) {
    var formContainer = form.parent();
    formContainer.remove();
    var commentActionLink = bottomBar.find("a.comment_action").first();
    commentActionLink.addClass("inactive");
    var toggleReactionsLink = bottomBar.find(".show_comments").first();
    showComments(toggleReactionsLink);
  }
});
