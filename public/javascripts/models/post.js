var Post = Backbone.Model.extend({
  url: "/posts/:id",
  intTime: function(){
    return +new Date(this.postAttributes().created_at);
  },

  postAttributes: function() {
    return this.attributes[_.keys(this.attributes)[0]];
  }
});
