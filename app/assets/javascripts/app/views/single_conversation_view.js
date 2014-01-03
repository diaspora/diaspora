app.views.SingleConversation = app.views.Base.extend({
  templateName: 'single-conversation',

  initialize: function() {
    var msg = this.options.messages;
    msg.on('reset', this._renderMessageStream, this);
    msg.on('add', this._reRenderMessageStream, this);
    msg.fetch({reset: true});
    this.messages = msg;
  },

  _renderMessageStream: function() {
    this._renderMessageList();
    this._renderMessageForm();
  },

  _reRenderMessageStream: function() {
    this._renderMessageStream();
    $(document).scrollTop($(document).height());
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
    form.on('create:message', this._createMessage, this);
    this.$('.stream').append(form.render().el);
  },

  _createMessage: function(params) {
    var msg = this.messages.create({ message: params}, {wait:true});
  }
});
