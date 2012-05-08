app.collections.Comments = Backbone.Collection.extend({
  model: app.models.Comment,

  url : function(){
    return this.post.url() + "/comments"
  },

  initialize : function(models, options) {
    this.post = options.post
  }
});
