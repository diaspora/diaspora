var Post = Backbone.Model.extend({
  url: "/posts/:id",
  intTime: function(){
    return +new Date(this.postAttributes().created_at) / 1000;
  },

  postAttributes: function() {
    return this.attributes[_.keys(this.attributes)[0]];
  }
});
