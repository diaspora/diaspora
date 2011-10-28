Diaspora.Pages.ContactsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.infiniteScroll = self.instantiate("InfiniteScroll");

    $(".aspect_membership.dropdown").each(function() {
      self.instantiate("AspectsDropdown", $(this));
    });

    $('.conversation_button').twipsy({position: 'below'});
  });
};
