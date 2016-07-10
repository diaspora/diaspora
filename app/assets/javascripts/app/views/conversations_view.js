// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Conversations = Backbone.View.extend({
  el: "#conversations_container",

  events: {
    "keydown textarea#message_text" : "keyDown",
    "click .conversation-wrapper": "displayConversation",
    "click .new-conversation-btn": "showNewConversation"
  },

  initialize: function() {
    if($("#conversation-new:visible").length > 0) {
      new app.views.ConversationsForm({
        el: $("#conversation-new"),
        contacts: gon.contacts
      });
    }
    this.setupConversation();
  },

  renderConversation: function(conversationId) {
    if(conversationId){
      var self = this;
      $.ajax({
        url: Routes.conversation(conversationId, {raw: true}),
        dataType: "html",
        success: function(data) {
          self.$el.find("#conversation-new").addClass("hidden");
          self.$el.find("#conversation-show").removeClass("hidden").html(data);
          self.$el.find("#conversation-inbox").removeClass("selected");
          self.$el.find(".stream_element[data-guid='" + conversationId + "'] #conversation-inbox").addClass("selected");
          self.setupConversation();
        }
      });
    }
  },

  showNewConversation: function(evt){
    evt.preventDefault();
    evt.stopPropagation();
    this.$el.find("#conversation-new").removeClass("hidden");
    this.$el.find("#conversation-show").addClass("hidden");
    app.router.navigate(Routes.conversations());
  },

  getContainer: function() {
    return this.$el.find(".stream_container");
  },

  setupConversation: function() {
    app.helpers.timeago($(this.el));
    $(".control-icons a").tooltip({placement: "bottom"});

    var conv = $(".conversation-wrapper .stream_element.selected"),
        cBadge = $("#conversations-link .badge");

    if(conv.hasClass("unread") ){
      var unreadCount = parseInt(conv.find(".unread-message-count").text(), 10);

      if(cBadge.text() !== "") {
        cBadge.text().replace(/\d+/, function(num){
          num = parseInt(num, 10) - unreadCount;
          if(num > 0) {
            cBadge.text(num);
          } else {
            cBadge.text(0).addClass("hidden");
          }
        });
      }
      conv.removeClass("unread");
      conv.find(".unread-message-count").remove();

      var pos = $("#first_unread").offset().top - 50;
      $("html").animate({scrollTop:pos});
    } else {
      $("html").animate({scrollTop:0});
    }
  },

  displayConversation: function(evt) {
    var $target = $(evt.target);
    if(!$target.hasClass(".conversation-wrapper")){
      $target = $target.parents(".conversation-wrapper");
    }
    app.router.navigate($target.data("conversation-path"), {trigger: true});
  },

  keyDown : function(evt) {
    if(evt.which === Keycodes.ENTER && evt.ctrlKey) {
      $(evt.target).parents("form").submit();
    }
  }
});
// @license-end

