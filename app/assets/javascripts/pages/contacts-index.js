Diaspora.Pages.ContactsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.infiniteScroll = self.instantiate("InfiniteScroll",
          {donetext: Diaspora.I18n.t("infinite_scroll.no_more_contacts"),});
    $('.conversation_button').tooltip({placement: 'bottom'});
  });

};
