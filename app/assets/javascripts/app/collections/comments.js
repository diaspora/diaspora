app.collections.Comments = Backbone.Collection.extend({
  model: app.models.Comment,

  url : function(){
    return this.post.url() + "/comments"
  },

  initialize : function(models, options) {
    this.post = options.post
  },

  make : function(text){
    var self = this

    var comment = new app.models.Comment({text: text })
      , deferred = comment.save({}, {url : self.url()}).done(function() {
        comment.set({author: app.currentUser.toJSON(), parent: self.post })
        self.add(comment)
      });

    return deferred
  }
});
