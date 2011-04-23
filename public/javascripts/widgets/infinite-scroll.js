/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var InfiniteScroll = function() {
    this.options = {
      navSelector  : "#pagination",
      nextSelector : ".paginate",
      itemSelector : ".stream_element",
      pathParse    : function( pathStr, nextPage ){
        var newPath = pathStr.replace("?", "?only_posts=true&");
        var last_time = $('#main_stream .stream_element').last().find('.time').attr('integer');
        return newPath.replace( /max_time=\d+/, 'max_time=' + last_time);
      },
      bufferPx: 500,
      debug: false,
      donetext: Diaspora.widgets.i18n.t("infinite_scroll.no_more"),
      loadingText: "",
      loadingImg: '/images/ajax-loader.gif'
    };

    this.start = function() {
      Diaspora.widgets.subscribe("stream/reloaded", InfiniteScroll.initialize);
      
      $('#main_stream').infinitescroll(this.options, function() {
        Diaspora.widgets.publish("stream/scrolled");
      });
    };
  };

  Diaspora.widgets.add("infinitescroll", InfiniteScroll)
})();

