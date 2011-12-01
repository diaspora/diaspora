var Post = Backbone.Model.extend({
  url: "/posts/:id",
  intTime: function(){
    return +new Date(this.get("created_at")) / 1000;
  },

  // should be moved into the view or something?
  currentUserJSON: function(){
    return $.parseJSON(unescape($("body").data("current-user-metadata")));
  }
});
