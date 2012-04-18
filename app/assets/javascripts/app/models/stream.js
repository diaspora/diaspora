//= require ../collections/posts
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

  fetch: function() {
    if(this.deferred && !this.deferred.isResolved()){ return false }
    var url = this.url()
    this.deferred = this.posts.fetch({
        add : true,
        url : url
    }).done(_.bind(this.triggerFetchedEvents, this))
  },

  triggerFetchedEvents : function(resp){
    this.trigger("fetched", this);
    // all loaded?
    if(resp.posts && (resp.posts.author || resp.posts.length == 0)) {
      this.trigger("allPostsLoaded", this);
    }
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
    return this.basePath().match(/activity/) ? "interactedAt" : "createdAt"
  },

  add : function(models){
    this.posts.add(models)
  }
});
