app.views.MessageForm = app.views.Base.extend({
  templateName: 'message-form',

  events: {
    'submit form': 'createMessage'
  },

  createMessage: function(ev) {
    if( ev ) ev.preventDefault();  // cancel event

    var msgText = $.trim(this.$('#message_text').val());
    if( msgText ) {
      this.$('input[type=submit]').val(Diaspora.I18n.t('conversations.replying'));
      this.$('form *').filter(':input').prop('disabled', true);
      this.trigger('create:message', {text: msgText});
    } else {
      this.$('#message_text').focus();
    }

    return this;  // chainability
  }
});
