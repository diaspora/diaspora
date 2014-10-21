// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

(function(){
  app.helpers.openGraph = {
    html : function (open_graph_cache) {
      if (!open_graph_cache) { return "" }
      return '<img src="' + open_graph_cache.image + '" />'
    }
  }
})();
// @license-end

