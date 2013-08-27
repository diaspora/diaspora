(function(){
  app.helpers.openGraph = {
    html : function (open_graph_cache) {
      if (!open_graph_cache) { return "" }
      return '<img src="' + open_graph_cache.image + '" />'
    }
  }
})();
