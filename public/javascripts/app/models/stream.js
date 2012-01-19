app.models.Stream = Backbone.Collection.extend({
  initialize : function(){
    this.posts = new app.collections.Posts();
  },

  url : function(){
    return _.any(this.posts.models) ? this.timeFilteredPath() : this.basePath()
  },

  fetch: function() {
    var self = this

    this.posts
      .fetch({
        add : true,
        url : self.url()
      })
      .done(
        function(response){ 
          self.trigger("fetched", self, response);
        }
      )
  },

  basePath : function(){
    return document.location.pathname;
  },

  timeFilteredPath : function(){
   return this.basePath() + "?max_time=" + _.last(this.posts.models).createdAt();
  },

  add : function(models){
    this.posts.add(models)
  }
})
