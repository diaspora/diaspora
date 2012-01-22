app.models.Stream = Backbone.Collection.extend({
  initialize : function(){
    this.posts = new app.collections.Posts();
  },

  url : function(){
    return _.any(this.posts.models) ? this.timeFilteredPath() : this.basePath()
  },

  _fetching : false,

  fetch: function() {
    if(this._fetching) { return false; }
    var self = this

    // we're fetching the collection... there is probably a better way to do this
    self._fetching = true;

    this.posts
      .fetch({
        add : true,
        url : self.url()
      })
      .done(
        function(resp){
          // we're done fetching... there is probably a better way to handle this
          self._fetching = false;

          self.trigger("fetched", self);

          // all loaded?
          if(resp.posts && (resp.posts.author || resp.posts.length == 0)) {
            self.trigger("allPostsLoaded", self);
          }
        }
      )
    return this;
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
