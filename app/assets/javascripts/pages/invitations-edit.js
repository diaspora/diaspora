Diaspora.Pages.InvitationsEdit = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    jQuery.ajaxSetup({'cache': true});
    $('#user_username').tooltip({trigger: 'focus', placement: 'right'});
  });
};
