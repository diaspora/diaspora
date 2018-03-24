//= require emojione
//= require favico.js/favico

//= require jquery.ui/ui/resizable
//= require jquery.ui/ui/draggable
//= require jquery.slimscroll/jquery.slimscroll
//= require jquery-colorbox
//= require jquery-fullscreen-plugin

//= require diaspora_jsxc

// initialize jsxc xmpp client
$(document).ready(function() {
  if (app.currentUser.authenticated()) {
    $.post("/user/auth_token", null, function(data) {
      if (jsxc && data['token']) {
        var jid = app.currentUser.get('diaspora_id');
        jsxc.init({
          root: '/assets/diaspora_jsxc',
          rosterAppend: 'body',
          otr: {
            debug: true,
            SEND_WHITESPACE_TAG: true,
            WHITESPACE_START_AKE: true
          },
          onlineHelp: "/help/chat",
          priority: {
            online: 1,
            chat: 1
          },
          displayRosterMinimized: function() {
            return false;
          },
          xmpp: {
            url: $('script#jsxc').data('endpoint'),
            username: jid.replace(/@.*?$/g, ''),
            domain: jid.replace(/^.*?@/g, ''),
            jid: jid,
            password: data.token,
            resource: 'diaspora-jsxc',
            overwrite: true,
            onlogin: true
          }
        });
      } else {
        console.error('No token found! Authenticated!?');
      }
    }, 'json');
  }
});
