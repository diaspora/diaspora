app.views.SingleConversation = app.views.Base.extend({
  templateName: 'single-conversation',

  initialize: function() {
    var msg = this.options.messages;
    msg.on('reset', this._renderMessageStream, this);
    msg.fetch({reset: true});
    this.messages = msg;
  },

  _renderMessageStream: function() {
    this._renderMessageList();
    this._renderMessageForm();
  },

  _renderMessageList: function() {
    var content = document.createDocumentFragment();
    this.messages.each( function(item) {
      var view = new app.views.Message({model: item});
      content.appendChild(view.render().el);
    });
    this.$('.stream').html(content);
  },

  _renderMessageForm: function() {
    var form = new app.views.MessageForm();
    this.$('.stream').append(form.render().el);
  }
});
