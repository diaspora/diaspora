/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
var Validation = {
  rules: { 
    username: {
      characters: /^(|[A-Za-z0-9_]{0,32})$/,
      length: [6, 32]
    }, 
    email: {
      characters: /^(([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,}))(, *(([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})))*$/
    }
  },
  events: { 
    usernameKeypress: function(evt) {
      if(evt.keyCode === 0) {
        return;
      }
      if(!Validation.rules.username.characters.test(this.value + String.fromCharCode(evt.keyCode))) {
        evt.preventDefault();
      }
    }, 
    emailKeypress: function(evt) {
      if(evt.keyCode === 0) {
        return;
      }
      if(!Validation.rules.email.characters.test(this.value + String.fromCharCode(evt.keyCode))) {
        $('#user_email').css('border-color', '#8B0000');
      } else {
        $('#user_email').css('border-color', '#666666');
      }
    }
  }
};

$(function() { 
  $("#user_username").keypress(Validation.events.usernameKeypress);
  $("#user_email").keypress(Validation.events.emailKeypress);
});
