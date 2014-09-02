app.views.Draft = app.views.Base.extend({

  el: "#conversation_new",

  events: {
    "keypress #contact_autocomplete": "setTo",
    "keypress #conversation_subject": "setSubject",
    "keypress #conversation_text": "setText"
  },

  initialize: function(options) {
    this.model = new app.models.Draft();
    this.model.set(this.model.getDraft());
  },

  render: function() {
    $('#contact_autocomplete').val(this.model.get('to'));
    $('#conversation_subject').val(this.model.get('subject'));
    $('#conversation_text').val(this.model.get('text'));
  },

  setTo: function(e) {
   this.model.set("to", e.currentTarget.value);
   this.model.saveDraft();
  },

  setSubject: function(e) {
   this.model.set("subject", e.currentTarget.value);
   this.model.saveDraft();
  },

  setText: function(e) {
   this.model.set("text", e.currentTarget.value);
   this.model.saveDraft();
  }

});
