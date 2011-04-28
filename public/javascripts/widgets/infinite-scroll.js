/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var InfiniteScroll = function() { };
  InfiniteScroll.prototype.options = function(){
    return {
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
  };

  InfiniteScroll.prototype.initialize = function(){
    $('#main_stream').infinitescroll(this.options(), function() {
      Diaspora.widgets.publish("stream/scrolled");
    });
  };

  InfiniteScroll.prototype.start = function() {
    Diaspora.widgets.subscribe("stream/reloaded", this.initialize, this);
    this.initialize();
  };

  Diaspora.widgets.add("infinitescroll", InfiniteScroll);
})();

