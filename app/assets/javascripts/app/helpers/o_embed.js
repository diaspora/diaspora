(function(){
  app.helpers.oEmbed = {
    html : function (o_embed_cache) {
      if (!o_embed_cache) { return "" }

      var data = o_embed_cache.data;
      if (data.type == "photo") {
        return '<img src="' + data.url + '" width="' + data.width + '" height="' + data.height + '" />'
      } else {
        return data.html || ""
      }
    }
  }
})();