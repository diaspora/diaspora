app.views.Conversation = app.views.Base.extend({
  templateName: 'conversation',

  events: {
    'click': '_conversationClicked'
  },

  _conversationClicked: function(ev) {
    this.trigger('click:conversation', this.model)
    return false;
  }

});
