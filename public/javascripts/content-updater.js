/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
var ContentUpdater = {
  elementWithGuid: function(selector, guid) {
    return $(selector + "[data-guid='" + guid + "']");
  },

  commentDoesNotExist: function(commentId) {
    return (ContentUpdater.elementWithGuid(".comment", commentId).length === 0);
  },

  postDoesNotExist: function(postId) {
    return (ContentUpdater.elementWithGuid(".stream_element", postId).length === 0);
  },

  addPostToStream: function(postId, html) {
    var streamElement = $(html);

    if (ContentUpdater.postDoesNotExist(postId)) {
      if ($("#no_posts").length) {
        $("#no_posts").detach();
      }

      streamElement.prependTo("#main_stream").fadeIn("fast", function() {
        streamElement.find("label").inFieldLabels();
      });

      Diaspora.widgets.publish("stream/postAdded", [postId]);
      Diaspora.widgets.timeago.updateTimeAgo();
      Diaspora.widgets.directionDetector.updateBinds();
    }
  },

  addCommentToPost: function(commentId, postId, html) {
    if (ContentUpdater.commentDoesNotExist(commentId)) {
      var post = ContentUpdater.elementWithGuid(".stream_element", postId),
        newComment = $(html),
        commentsContainer = $(".comments", post),
        comments = commentsContainer.find(".comment.posted"),
        showCommentsToggle = $(".show_post_comments", post);

      if(comments.length === 0) {
        comments
          .last()
          .after(
            newComment.fadeIn("fast")
          );
      }
      else {
        commentsContainer
          .find("li")
          .last()
          .before(
            newComment.fadeIn("fast")
          );
      }


      if (showCommentsToggle.length > 0) {
        showCommentsToggle.html(
          showCommentsToggle.html().replace(/\d+/, comments.length)
        );

        if (comments.is(":not(:visible)")) {
          showCommentsToggle.click();
        }

        $(".show_comments", post).removeClass('hidden');

        Diaspora.widgets.publish("stream/commentAdded", [postId, commentId]);
        Diaspora.widgets.timeago.updateTimeAgo();
        Diaspora.widgets.directionDetector.updateBinds();
      }
    }
  }
};