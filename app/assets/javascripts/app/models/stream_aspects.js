// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.StreamAspects = app.models.Stream.extend({

  url : function(){
    return _.any(this.items.models) ? this.timeFilteredPath() : this.basePath();
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
    if(this.isFetching()) { return false; }
    var url = this.url();
    var ids = this.aspects_ids;
    this.deferred = this.items.fetch(this._fetchOpts({url : url, data : { 'a_ids': ids }}))
      .done(_.bind(this.fetchDone, this));
  },

  fetchDone: function() {
    this.triggerFetchedEvents();
    if (app.aspectSelections) {
      app.aspectSelections.trigger("aspectStreamFetched");
    }
  }
});
// @license-end
