// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.Pages.ContactsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.infiniteScroll = self.instantiate("InfiniteScroll",
          {donetext: Diaspora.I18n.t("infinite_scroll.no_more_contacts"),});
    $('.conversation_button').tooltip({placement: 'bottom'});
  });

};
// @license-end

