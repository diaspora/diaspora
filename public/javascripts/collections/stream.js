var BackboneStream = Backbone.Collection.extend({
  url: function() {
    if(this.models.length) {
      return "stream.json?max_time=" + _.last(this.models).intTime() / 1000;
    }
    else {
      return "stream.json";
    }
  },

  model: Post
});
