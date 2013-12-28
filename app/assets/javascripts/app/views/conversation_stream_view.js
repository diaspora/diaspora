app.views.ConversationStream = Backbone.View.extend({
  initialize: function() { },

  render: function() {
    var content = document.createDocumentFragment();
    this.collection.each( function(item) {
      content.appendChild((new app.views.Conversation({model: item})).render().el);
    });
    this.$el.html(content);
  }

});
