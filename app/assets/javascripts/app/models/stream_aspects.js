app.models.StreamAspects = app.models.Stream.extend({

  url : function(){
    return _.any(this.items.models) ? this.timeFilteredPath() : this.basePath()
  },

  initialize : function(models, options){
    var collectionClass = options && options.collection || app.collections.Posts;
    this.items = new collectionClass([], this.collectionOptions());
    this.aspects_ids = options.aspects_ids;
  },

  basePath : function(){
    return '/aspects';
  },

  fetch: function() {
    if(this.isFetching()){ return false }
    var url = this.url();
    var ids = this.aspects_ids;
    this.deferred = this.items.fetch(this._fetchOpts({url : url, data : { 'a_ids': ids }}))
      .done(_.bind(this.triggerFetchedEvents, this));
  }
});
