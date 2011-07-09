/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

var ContentUpdater = {
  addPostToStream: function(html) {
    var streamElement = $(html);
    var postGUID = streamElement.id;

    if($("#"+postGUID).length === 0) {
      if($("#no_posts").length) {
        $("#no_posts").detach();
      }

      streamElement.prependTo("#main_stream:not('.show')").fadeIn("fast", function() {
        streamElement.find("label").inFieldLabels();
      });

      Diaspora.widgets.publish("stream/postAdded", [postGUID]);
      Diaspora.widgets.timeago.updateTimeAgo();
      Diaspora.widgets.directionDetector.updateBinds();
    }
  },

  addLikesToPost: function(postGUID, html) {
    var post = $("#" + postGUID);

    $(".likes_container", post)
      .fadeOut("fast")
      .html(html)
      .fadeIn("fast");
  }
  
};
