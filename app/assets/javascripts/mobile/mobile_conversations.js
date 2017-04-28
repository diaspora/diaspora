(function() {
  Diaspora.Mobile.Conversations = {
    initialize: function() {
      if (Diaspora.Page !== "ConversationsNew") { return; }
      $(document).on("ajax:success", "form#new-conversation", this.conversationCreateSuccess);
      $(document).on("ajax:error", "form#new-conversation", this.conversationCreateError);
    },

    conversationCreateSuccess: function(evt, data) {
      Diaspora.Mobile.changeLocation(Routes.conversation(data.id));
    },

    conversationCreateError: function(evt, response) {
      Diaspora.Mobile.Alert.handleAjaxError(response);
    }
  };
})();

$(document).ready(function() {
  Diaspora.Mobile.Conversations.initialize();
});
