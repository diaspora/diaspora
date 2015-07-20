// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

(function(){
  app.helpers.oEmbed = {
    html : function (o_embed_cache) {
      if (!o_embed_cache) { return "" }

      var data = o_embed_cache.data;
      if (data.type === "photo") {
        return '<img src="' + data.url + '" width="' + data.width + '" height="' + data.height + '" />';
      } else {
        return data.html || "";
      }
    }
  };
})();
// @license-end
