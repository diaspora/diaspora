/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
      Diaspora.page.stream.addPost(streamElement);
      Diaspora.page.publish("stream/postAdded", [postGUID]);
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

    Diaspora.page
      .stream
      .streamElements[postGUID]
      .commentStream
      .publish("comment/added", [$("#"+commentGUID)]);
  },

  addLikesToPost: function(postGUID, html) {
    var likesContainer = $(".likes_container:first", "#" + postGUID)
      .fadeOut("fast")
      .html(html);

    Diaspora.page.publish("likes/" + postGUID + "/updated");

    likesContainer.fadeIn("fast");
  }
};
