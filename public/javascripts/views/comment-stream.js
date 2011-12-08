App.Views.CommentStream = Backbone.View.extend({
  initialize: function(options) {
    this.collection = options.collection;
  },

  render: function() {
    var self = this;
    
    this.collection.each(function(comment) {
      $(self.el).append(new App.Views.Comment({
        model: comment
      }).render());
    });

    return this.el;
  }
});
