/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

var ContentUpdates = {
  addPostToStream: function(postId, html) {
    if( $(".stream_element[data-guid='" + postId + "']").length === 0 ) {
      var streamElement = $(html);

      if($("#no_posts").length) {
        $("#no_posts").detach();
      }

      streamElement.prependTo("#main_stream:not('.show')").fadeIn("fast", function() {
        streamElement.find("label").inFieldLabels();
      });


      Diaspora.widgets.publish("stream/postAdded", [postId]);
      
      Diaspora.widgets.timeago.updateTimeAgo();
      Diaspora.widgets.directionDetector.updateBinds();
    }
  }
};