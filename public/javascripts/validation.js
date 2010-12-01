/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
var Validation = {
  rules: { 
    username: {
      characters: /^(|[A-Za-z0-9_]{0,32})$/,
      length: [6, 32]
    }
  },
  events: { 
    usernameKeypress: function(evt) {
      if(!Validation.rules.username.characters.test(this.value + String.fromCharCode(evt.charCode))) {
        evt.preventDefault();
      }
    }
  }
};

$(function() { 
  $("#user_username").keypress(Validation.events.usernameKeypress);
});
