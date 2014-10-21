// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.Pages.InvitationsEdit = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    jQuery.ajaxSetup({'cache': true});
    $('#user_username').tooltip({trigger: 'focus', placement: 'right'});
  });
};
// @license-end

