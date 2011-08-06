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
  whiteListed: function(keyCode) {
    var keyCodes = [0, 37, 38, 39, 40, 8, 9];
    return $.grep(keyCodes, function(element) { return keyCode !== element; }).length === keyCodes.length - 1;
  },

  events: { 
    usernameKeypress: function(evt) {
      if(Validation.whiteListed(evt.keyCode)) {
        return;
      }

      if(!Validation.rules.username.characters.test(this.value + String.fromCharCode(evt.keyCode))) {
        evt.preventDefault();
      }
    },

    emailKeypress: function(evt) {
      if(Validation.whiteListed(evt.keyCode)) {
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
