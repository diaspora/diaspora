app.models.Photos = Backbone.Model.extend({
  initialize : function(){
    this.photos = new app.collections.Photos([], this.photoOptions());
  },

  photoOptions :function(){
      var order = this.sortOrder();
      return {
          comparator : function(photo) { return -photo[order](); }
      }
  },

  url : function() {
    return _.any(this.photos.models) ? this.timeFilteredPath() : this.basePath()
  },

  _fetching : false,

  fetch : function(){
    if(this._fetching) { return false; }
    var self = this;

    // we're fetching the collection... there is probably a better way to do this
    self._fetching = true;

    this.photos
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
          if(resp.photos && resp.photos.length == 0) {
            self.trigger("allPostsLoaded", self);
          }
        }
      );
      
    return this;
  },
  
  basePath : function(){
    return document.location.pathname;
  },

  timeFilteredPath : function(){
   return this.basePath() + "?max_time=" + this.maxTime();
  },

  maxTime: function(){
    var lastPost = _.last(this.photos.models);
    return lastPost[this.sortOrder()]()
  },

  sortOrder : function() {
    return "createdAt";
  },

  add : function(models){
    this.photos.add(models)
  }

});