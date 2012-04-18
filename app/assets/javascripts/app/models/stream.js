//= require ../collections/posts
//= require ../collections/photos
app.models.Stream = Backbone.Collection.extend({
  initialize : function(models, options){
    var collection = app.collections.Posts;
    if( options && options.collection ) collection = options.collection;
    this.items = new collection([], this.collectionOptions());
  },

  collectionOptions :function(){
      var order = this.sortOrder();
      return {
          comparator : function(item) { return -item[order](); }
      }
  },

  url : function(){
    return _.any(this.items.models) ? this.timeFilteredPath() : this.basePath()
  },

  fetch: function() {
    if(this.isFetching()){ return false }
    var url = this.url()
    this.deferred = this.items.fetch({
        add : true,
        url : url
    }).done(_.bind(this.triggerFetchedEvents, this))
  },

  isFetching : function(){
    return this.deferred && this.deferred.state() == "pending"
  },

  triggerFetchedEvents : function(resp){
    this.trigger("fetched", this);
    // all loaded?
    var respItems = this.items.parse(resp);
    if(respItems && (respItems.author || respItems.length == 0)) {
      this.trigger("allItemsLoaded", this);
    }
  },

  basePath : function(){
    return document.location.pathname;
  },

  timeFilteredPath : function(){
   return this.basePath() + "?max_time=" + this.maxTime();
  },

  maxTime: function(){
    var lastPost = _.last(this.items.models);
    return lastPost[this.sortOrder()]()
  },

  sortOrder : function() {
    return this.basePath().match(/activity/) ? "interactedAt" : "createdAt"
  },

  add : function(models){
    this.items.add(models)
  }
});
