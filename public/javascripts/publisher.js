/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//TODO: make this a widget
var Publisher = {
  initialize: function() {
    var $publisher = $("#publisher");
    $("div.public_toggle input").live("click", function(evt) {
      $("#publisher_service_icons").toggleClass("dim");
      if ($(this).attr('checked') == true) {
        $(".question_mark").click();
      }
    });

    if ($("#status_message_message").val() != "") {
      $publisher
          .removeClass("closed")
          .find("textarea")
          .focus();

      $publisher
          .find(".options_and_submit")
          .show();
    }

    $publisher.find("textarea").live("focus", function(evt) {
      $publisher.find(".options_and_submit").show();
    });

    $publisher.find("textarea").live("click", function(evt) {
      $publisher
          .removeClass("closed")
          .find("textarea")
          .focus();
    });


    $publisher.find("textarea").bind("focus", function() {
      $(this)
          .css('min-height', '42px');
    });

    $publisher.find("form").bind("blur", function() {
      $publisher
          .find("textarea")
          .css('min-height', '2px');
    });
  }
};

$(document).ready(function() {
  Publisher.initialize();
});
