var BackboneStream = Backbone.Collection.extend({
  url: function() {
    var path = document.location.pathname;

    if(this.models.length) {
      return path + ".json?max_time=" + _.last(this.models).intTime();
    }
    else {
      return path + ".json";
    }
  },

  model: Post
});
