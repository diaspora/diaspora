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
    this.autocompleteInput = $("#contact_autocomplete");
    this.prepareAutocomplete(gon.contacts);

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
  },

  prepareAutocomplete: function(data){
    this.autocompleteInput.autoSuggest(data, {
      selectedItemProp: "name",
      searchObjProps: "name",
      asHtmlID: "contact_ids",
      retrieveLimit: 10,
      minChars: 1,
      keyDelay: 0,
      startText: '',
      emptyText: Diaspora.I18n.t('no_results'),
    }).focus();
  }
});
