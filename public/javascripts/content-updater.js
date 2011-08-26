/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

var ContentUpdater = {
  addPostToStream: function(html) {
    var streamElement = $(html);
    var postGUID = $(streamElement).attr('id');

    if($("#"+postGUID).length === 0) {
      if($("#no_posts").length) {
        $("#no_posts").detach();
      }

      streamElement.prependTo("#main_stream:not('.show')").fadeIn("fast", function() {
        streamElement.find("label").inFieldLabels();
      });

      Diaspora.page.publish("stream/postAdded", [postGUID]);
      Diaspora.page.timeAgo.updateTimeAgo();
      Diaspora.page.directionDetector.updateBinds();
    }
  },

  removePostFromStream: function(postGUID) {
    $("#" + postGUID).fadeOut(400, function() {
      $(this).remove();
    });

    if(!$("#main_stream .stream_element").length) {
      $("#no_posts").removeClass("hidden");
    }
  },

  addCommentToPost: function(postGUID, commentGUID, html) {
    var post = $("#" + postGUID),
      comments = $("ul.comments", post);

    if($("#" + commentGUID, post).length) { return; }

    $(html).appendTo(comments).fadeIn("fast");

    Diaspora.page.timeAgo.updateTimeAgo();
    Diaspora.page.directionDetector.updateBinds()
  },

  addLikesToPost: function(postGUID, html) {
    var likesContainer = $(".likes_container", "#" + postGUID)
      .fadeOut("fast")
      .html(html);

    Diaspora.page.stream.streamElements[postGUID].likes.publish("widget/ready", [likesContainer]);

    likesContainer.fadeIn("fast");
  }
};
