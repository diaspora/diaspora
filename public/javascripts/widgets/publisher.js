/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  var Publisher = function() {
    var self = this;

    this.start = function() {
      this.$publisher = $("#publisher");
      this.$realMessage = this.$publisher.find("#status_message_message");
      this.$fakeMessage = this.$publisher.find("#status_message_fake_message");

      if(this.$fakeMessage.val() === "") {
        this.toggle();
      }


      $("div.public_toggle input").live("click", function(evt) {
        $("#publisher_service_icons").toggleClass("dim");
        if (this.checked) {
          $(".question_mark").click();
        }
      });

      self
        .$publisher
        .find("textarea")
        .focus(self.toggle)
        .blur(self.toggle);


      self
        .$fakeMessage
        .change(self.updateHiddenField);

      self.updateHiddenField();
    };

    this.toggle = function() { 
      self
        .$publisher
        .toggleClass("closed")
        .find(".options_and_submit")
        .toggle(
          !self.$publisher.hasClass("closed")
        );

      self
        .$fakeMessage
        .css("min-height", (self.$publisher.hasClass("closed"))
          ? ""
          : "42px");
    };

    this.updateHiddenField = function() {
      self
        .$realMessage
        .val(
          self.$fakeMessage.val()
        );
    };
  };

  Diaspora.widgets.add("publisher", Publisher);

})();
