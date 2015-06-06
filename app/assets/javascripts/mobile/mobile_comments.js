/*
 *  Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function() {

  $(".stream").on("tap click", "a.back_to_stream_element_top", function(evt) {
    var bottomBar = $(this).closest(".bottom_bar").first();
    var streamElement = bottomBar.parent();
    $("html, body").animate({
      scrollTop: streamElement.offset().top - 54
    }, 1000);
  });

  $(".stream").on("tap click", "a.show_comments", function(evt){
    evt.preventDefault();
    var toggleReactionsLink = $(this),
        bottomBar = toggleReactionsLink.closest(".bottom_bar").first(),
        commentActionLink = bottomBar.find("a.comment_action"),
        commentsContainer = function() { return bottomBar.find(".comment_container").first(); },
        existingCommentsContainer = commentsContainer();
    if (toggleReactionsLink.hasClass("active")) {
      existingCommentsContainer.hide();
      toggleReactionsLink.removeClass("active");
    } else if (existingCommentsContainer.length > 0) {
      existingCommentsContainer.show();
      showCommentBox(commentActionLink);
      toggleReactionsLink.addClass('active');
      commentsContainer().find("time.timeago").timeago();
    } else {
      $.ajax({
        url: toggleReactionsLink.attr('href'),
        success: function(data) {
          $(data).insertAfter(bottomBar.children(".show_comments").first());
          showCommentBox(commentActionLink);
          toggleReactionsLink.addClass("active");
          commentsContainer().find("time.timeago").timeago();
        }
      });
    }
  });

  var scrollToOffset = function(commentsContainer){
    var commentCount = commentsContainer.find("li.comment").length;
    if ( commentCount > 3 ) {
      var lastComment = commentsContainer.find("li:nth-child("+(commentCount-3)+")");
      $('html,body').animate({
        scrollTop: lastComment.offset().top
      }, 1000);
    }
  };

  $(".stream").on("tap click", "a.comment_action", function(evt){
    evt.preventDefault();
    showCommentBox(this);
    var bottomBar = $(this).closest(".bottom_bar").first();
    scrollToOffset(bottomBar.find(".comment_container").first());
  });

  function showCommentBox(link){
    var link = $(link);
    if(link.hasClass("inactive")) {
      $.ajax({
        url: link.attr("href"),
        beforeSend: function(){
          link.addClass("loading");
        },
        context: link,
        success: function(data){
          appendCommentBox.call(this, link, data);
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
    scrollToFirstComment(bottomBar);
  }

  function scrollToFirstComment(bottomBar) {
    $("html, body").animate({
      scrollTop: bottomBar.offset().top - 54
    }, 500);
  }

  $(".stream").on("submit", ".new_comment", function(evt) {
    evt.preventDefault();
    var form = $(this);
    $.post(form.attr('action')+"?format=mobile", form.serialize(), function(data) {
      updateStream(form, data);
    }, 'html');
  });

  function updateStream(form, data) {
    var bottomBar = form.closest(".bottom_bar").first();
    addNewComments(bottomBar, data);
    updateCommentCount(bottomBar);
    updateReactionCount(bottomBar);
    handleNewCommentBox(form, bottomBar);
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

  function handleNewCommentBox(form, bottomBar) {
    form.parent().remove();
    var commentActionLink = bottomBar.find("a.comment_action").first();
    commentActionLink.addClass("inactive");
    showCommentBoxIfApplicable(bottomBar, commentActionLink);
  }
  function showCommentBoxIfApplicable(bottomBar, commentActionLink) {
    var toggleReactionsLink = bottomBar.find(".show_comments").first();
    if (toggleReactionsLink.hasClass("active")) {
      showCommentBox(commentActionLink);
    }
  }
});
