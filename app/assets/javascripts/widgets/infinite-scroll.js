// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var InfiniteScroll = function() {
    var self = this;
    this.options = {
      bufferPx: 500,
      debug: false,
      donetext: Diaspora.I18n.t("infinite_scroll.no_more"),
      loadingText: "",
      loadingImg: ImagePaths.get("ajax-loader.gif"),
      navSelector: "#pagination",
      nextSelector: ".paginate",
      itemSelector: ".stream_element",
      pathParse: function(pathStr) {
        var newPath = pathStr.replace("?", "?only_posts=true&"),
        	lastTime = $('#main_stream .stream_element').last().find(".time").attr("integer");

        if(lastTime === undefined){
        	lastTime = $('#main_stream').data('time_for_scroll');
        }

        return newPath.replace(/max_time=\d+/, "max_time=" + lastTime);
      }
    };

    this.subscribe("widget/ready", function(evt, opts) {
      $.extend(self.options, opts);
      if($('#main_stream').length !== 0) {
        $('#main_stream').infinitescroll(self.options, function(newElements) {
          self.globalPublish("stream/scrolled", newElements);
        });
      } else if($('#people_stream').length !== 0) {
        $("#people_stream").infinitescroll($.extend(self.options, {
          navSelector  : ".pagination",
          nextSelector : ".next_page",
          pathParse : function(pathStr, nextPage) {
            return pathStr.replace("page=2", "page=" + nextPage);
          }
        }), function(newElements) {
          self.globalPublish("stream/scrolled", newElements);
        });
      }
    });

    this.reInitialize = function() {
      $("#main_stream").infinitescroll("destroy");
      self.publish("widget/ready");
    };

    this.globalSubscribe("stream/reloaded", self.reInitialize, this);
  };

  Diaspora.Widgets.InfiniteScroll = InfiniteScroll;
})();
// @license-end

