// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Conversations = Backbone.View.extend({

  el: "#conversations_container",

  events: {
    "mouseenter .stream_element.conversation" : "showParticipants",
    "mouseleave .stream_element.conversation" : "hideParticipants"
  },

  initialize: function() {
    $("#people_stream.contacts .header .entypo").tooltip({ 'placement': 'bottom'});
    // TODO doesn't work anymore
    if ($('#first_unread').length > 0) {
      $("html").scrollTop($('#first_unread').offset().top-50);
    }

    new app.views.ConversationsForm({contacts: gon.contacts});

    $('.timeago').each(function(i,e) {
        var jqe = $(e);
        jqe.attr('title', new Date(jqe.attr('datetime')).toLocaleString());
      })
      .timeago()
      .tooltip();
  },

  hideParticipants: function(e){
    $(e.currentTarget).find('.participants').slideUp('300');
  },

  showParticipants: function(e){
    $(e.currentTarget).find('.participants').slideDown('300');
  }
});
// @license-end

