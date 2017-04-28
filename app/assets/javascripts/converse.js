//= require converse.js.js

// initialize converse xmpp client
$(document).ready(function() {
  if (app.currentUser.authenticated()) {
    $.post("/user/auth_token", null, function(data) {
      if (converse && data.token) {
        converse.initialize({
          bosh_service_url: $("script#converse").data("endpoint"),
          auto_login: true,
          jid: app.currentUser.get("diaspora_id"),
          password: data.token,
          debug: true,
          allow_registration: false,
          auto_reconnect: true,
          keepalive: true
        });
      } else {
        console.error("No token found! Authenticated!?");
      }
    }, "json");
  }
});
