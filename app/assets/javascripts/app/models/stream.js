//= require ../collections/posts
//= require ../collections/photos
app.models.Stream = Backbone.Collection.extend({
  initialize : function(models, options){
    var collectionClass = options && options.collection || app.collections.Posts;
    this.items = new collectionClass([], this.collectionOptions());
  },

  collectionOptions :function(){
      var order = this.sortOrder();
      return { comparator : function(item) { return -item[order](); } }
  },

  url : function(){
    return _.any(this.items.models) ? this.timeFilteredPath() : this.basePath()
  },

  _fetchOpts: function(opts) {
    var defaultOpts = {
      remove: false  // tell backbone to keep existing items in the collection
    };
    return _.extend({ url: this.url() }, defaultOpts, opts);
  },

  fetch: function() {
    if( this.isFetching() ) return false;
    this.deferred = this.items.fetch( this._fetchOpts() )
      .done(_.bind(this.triggerFetchedEvents, this));
  },

  isFetching : function() {
    return (this.deferred && this.deferred.state() == "pending");
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

  /* This function is for adding a large number of posts one by one.
   * Mainly used by backbone when loading posts from the server
   *
   * After adding the posts, you have to trigger "fetched" on the
   * stream for the changes to take effect in the infinite stream view
   */
  add : function(models){
    this.items.add(models)
  },

  /* This function is for adding a single post. It immediately triggers
   * "fetched" on the stream, so the infinite stream view updates
   * automatically.
   */
  addNow : function(models){
    this.add(models);
    this.trigger("fetched");
  },

  preloadOrFetch : function(){ //hai, plz test me THNX
    return $.when(app.hasPreload("stream") ? this.preload() : this.fetch())
  },

  preload : function(){
    this.items.reset(app.parsePreload("stream"))
    this.deferred = $.when(true)
    this.trigger("fetched")
  }
});
