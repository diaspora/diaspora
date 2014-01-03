app.views.SingleConversation = app.views.Base.extend({
  templateName: 'single-conversation',

  initialize: function() {
    var msg = this.options.messages;
    msg.on('reset', this.renderMessageStream, this);
    msg.fetch({reset: true});
    this.messages = msg;
  },

  renderMessageStream: function() {
    var content = document.createDocumentFragment();
    this.messages.each( function(item) {
      var view = new app.views.Message({model: item});
      content.appendChild(view.render().el);
    });
    this.$('.stream').html(content);
  }
});
