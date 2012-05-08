Diaspora.Pages.InvitationsNew = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    var rtl = $('html').attr('dir') == 'rtl',
        position = rtl ? 'left' : 'right';

    $('#new_user [title]').tooltip({trigger: 'focus', placement: position});
    $('#user_email').focus();
  });
};

