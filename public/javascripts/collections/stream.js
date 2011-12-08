App.Collections.Stream = Backbone.Collection.extend({
  url: function() {
    var path = document.location.pathname + ".json";

    if(this.models.length) { path += "?max_time=" + _.last(this.models).createdAt(); }

    return path;
  },

  model: App.Models.Post,

  parse: function(resp){
    return resp.posts;
  }
});
