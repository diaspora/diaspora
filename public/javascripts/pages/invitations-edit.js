Diaspora.Pages.InvitationsEdit = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    $('#user_username').tipsy({trigger: 'select', gravity: 'w'});

  });
};
