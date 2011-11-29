$(function() {
  window.StreamView = Backbone.View.extend({

    el: $("#main_stream"),

    template: _.template($('#stream-element-template').html()),

    initialize: function(){
      _.bindAll(this, "appendPost");

      this.collection = new window.BackboneStream;
      this.collection.bind("add", this.appendPost);
      this.collection.fetch({add: true});
    },

    appendPost: function(model) {
      $(this.el).append(this.template(model.toJSON()));
    },
  });

  if(window.useBackbone) {
    window.stream = new window.StreamView;
  }
});
