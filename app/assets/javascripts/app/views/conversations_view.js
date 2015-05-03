// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Conversations = Backbone.View.extend({

  el: "#conversations_container",

  events: {
    "conversation:loaded" : "setupConversation"
  },

  initialize: function() {
    if($('#conversation_new:visible').length > 0) {
      new app.views.ConversationsForm({contacts: gon.contacts});
    }
    this.setupConversation();
  },

  setupConversation: function() {
    app.helpers.timeago($(this.el));
    $('.control-icons a').tooltip({placement: 'bottom'});

    var conv = $('.conversation-wrapper .stream_element.selected'),
        cBadge = $('#conversations_badge .badge_count');

    if(conv.hasClass('unread') ){
      var unreadCount = parseInt(conv.find('.unread_message_count').text(), 10);

      if(cBadge.text() !== '') {
        cBadge.text().replace(/\d+/, function(num){
          num = parseInt(num, 10) - unreadCount;
          if(num > 0) {
            cBadge.text(num);
          } else {
            cBadge.text(0).addClass('hidden');
          }
        });
      }
      conv.removeClass('unread');
      conv.find('.unread_message_count').remove();

      var pos = $('#first_unread').offset().top - 50;
      $("html").animate({scrollTop:pos});
    } else {
      $("html").animate({scrollTop:0});
    }
  }
});
// @license-end

