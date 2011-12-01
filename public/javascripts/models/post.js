var Post = Backbone.Model.extend({
  url: "/posts/:id",
  intTime: function(){
    return +new Date(this.get("created_at")) / 1000;
  }
});
