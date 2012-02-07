app.models.Stream = Backbone.Collection.extend({
  initialize : function(){
    this.posts = new app.collections.Posts([], this.postOptions());
  },

  postOptions :function(){
      var order = this.sortOrder();
      return {
          comparator : function(post) { return -post[order](); }
      }
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
   return this.basePath() + "?max_time=" + this.maxTime();
  },

  maxTime: function(){
    var lastPost = _.last(this.posts.models);
    return lastPost[this.sortOrder()]()
  },

  sortOrder : function() {
    return this.basePath().match(/participate/) ? "interactedAt" : "createdAt"
  },

  add : function(models){
    this.posts.add(models)
  }
})
