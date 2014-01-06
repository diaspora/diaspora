app.views.ConversationStream = Backbone.View.extend({
  initialize: function() {
    this.collection.on('sync', this.render, this);
  },

  render: function() {
    var self = this;
    var content = document.createDocumentFragment();
    if( this.collection.isEmpty() ) {
      content = $('<div id="no_conversations" />')
                  .text(Diaspora.I18n.t('conversations.no_messages'));
    } else {
      this.collection.each( function(item) {
        var view = new app.views.Conversation({model: item});
        view.on('click:conversation', self._openConversation, self);

        content.appendChild(view.render().el);
      });
    }
    this.$el.html(content);
  },

  _openConversation: function(model) {
    app.router.navigate('/conversations/'+model.id);

    var messages = new app.collections.Messages([], {
      url: model.url()+'/messages'
    });
    messages.on('add', this._messageAdded, this);

    app.conversation = new app.views.SingleConversation({
      el: $('#conversation_show'),
      model: model,
      messages: messages
    });

    app.conversation.render();
  },

  _messageAdded: function() {
    this.collection.fetch();
  }

});
