//= require diaspora_jsxc

// initialize jsxc xmpp client
$(document).ready(function() {
  if (app.currentUser.authenticated()) {
    $.post('api/v1/tokens', null, function(data) {
      if (jsxc && data['token']) {
        var jid = app.currentUser.get('diaspora_id');
        jsxc.init({
          root: '/assets/diaspora_jsxc',
          checkFlash: false,
          logoutElement: $('.user-menu-item [data-method=delete]'),
          rosterAppend: 'body',
          otr: {
            debug: true,
            SEND_WHITESPACE_TAG: true,
            WHITESPACE_START_AKE: true
          },
          autoLang: true,
          priority: {
            online: 1,
            chat: 1
          },
          xmpp: {
            url: $('script#jsxc').data('endpoint'),
            username: jid.replace(/@.*?$/g, ''),
            domain: jid.replace(/^.*?@/g, ''),
            jid: jid,
            password: data['token'],
            resource: 'diaspora-jsxc',
            overwrite: true,
            onlogin: true
          }
        });
        // TODO unset debug on default (testing version)
        jsxc.storage.setItem('debug', true);
        jsxc.login();
      } else {
        console.error('No token found! Authenticated!?');
      }
    }, 'json');
  }
});
