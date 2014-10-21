// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.Pages.InvitationsNew = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    var rtl = $('html').attr('dir') == 'rtl',
        position = rtl ? 'left' : 'right';

    $('#new_user [title]').tooltip({trigger: 'focus', placement: position});
    $('#user_email').focus();
  });
};
// @license-end

