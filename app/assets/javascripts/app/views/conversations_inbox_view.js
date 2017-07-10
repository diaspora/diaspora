// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ConversationsInbox = app.views.Base.extend({
  el: "#conversations-container",

  events: {
    "click .conversation-wrapper": "displayConversation",
    "click .new-conversation-btn": "displayNewConversation"
  },

  initialize: function(conversationId) {
    this.conversationForm = new app.views.ConversationsForm();

    // Creates markdown editor in case of displaying preloaded conversation
    if (conversationId != null) {
      this.renderMarkdownEditor();
    }

    this.setupConversation();
  },

  renderMarkdownEditor: function() {
    this.conversationForm.renderMarkdownEditor("#conversation-show .conversation-message-text");
  },

  renderConversation: function(conversationId) {
    var self = this;
    $.ajax({
      url: Routes.conversationRaw(conversationId),
      dataType: "html",
      success: function(data) {
        self.$el.find("#conversation-new").addClass("hidden");
        self.$el.find("#conversation-show").removeClass("hidden").html(data);
        self.selectConversation(conversationId);
        self.setupConversation();
        self.renderMarkdownEditor();
        autosize(self.$("#conversation-show textarea"));
      }
    });
  },

  selectConversation: function(conversationId) {
    this.$el.find("#conversation-inbox .stream-element").removeClass("selected");
    if (conversationId) {
      this.$el.find("#conversation-inbox .stream-element[data-guid='" + conversationId + "']").addClass("selected");
    }
  },

  displayNewConversation: function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    this.$el.find("#conversation-new").removeClass("hidden");
    this.$el.find("#conversation-show").addClass("hidden");
    this.selectConversation();
    app.router.navigate(Routes.conversations());
  },

  setupConversation: function() {
    app.helpers.timeago($(this.el));
    $(".control-icons a").tooltip({placement: "bottom"});
    this.setupAvatarFallback(this.$el);

    var conv = $(".conversation-wrapper .stream-element.selected"),
        cBadge = $("#conversations-link .badge");

    if (conv.hasClass("unread")) {
      var unreadCount = parseInt(conv.find(".unread-message-count").text(), 10);

      if (cBadge.text() !== "") {
        cBadge.text().replace(/\d+/, function(num) {
          num = parseInt(num, 10) - unreadCount;
          if (num > 0) {
            cBadge.text(num);
          } else {
            cBadge.text(0).addClass("hidden");
          }
        });
      }
      conv.removeClass("unread");
      conv.find(".unread-message-count").remove();

      var pos = $("#first_unread").offset().top - 50;
      $("html").animate({scrollTop: pos});
    } else {
      $("html").animate({scrollTop: 0});
    }
  },

  displayConversation: function(evt) {
    var $target = $(evt.target).closest(".conversation-wrapper");
    app.router.navigate($target.data("conversation-path"), {trigger: true});
  }
});
// @license-end

