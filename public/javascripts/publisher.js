/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//TODO: make this a widget
var Publisher = {
  close: function(){
    Publisher.form().addClass('closed');
    Publisher.form().find(".options_and_submit").hide();
         },
  open: function(){
    Publisher.form().removeClass('closed');
    Publisher.form().find(".options_and_submit").show();
  },
  form: function(){return $('#publisher');},
  updateHiddenField: function(evt){
    Publisher.form().find('#status_message_message').val(
        Publisher.form().find('#status_message_fake_message').val());
  },
  initialize: function() {
    var $publisher = Publisher.form();
    $("div.public_toggle input").live("click", function(evt) {
      $("#publisher_service_icons").toggleClass("dim");
      if ($(this).attr('checked') == true) {
        $(".question_mark").click();
      }
    });

    if ($("#status_message_fake_message").val() == "") {
      Publisher.close();
    };

    Publisher.updateHiddenField();
    $publisher.find('#status_message_fake_message').change(
        Publisher.updateHiddenField);
    $publisher.find("textarea").bind("focus", function(evt) {
      Publisher.open();
      $(this).css('min-height', '42px');
    });
  }
};

$(document).ready(function() {
  Publisher.initialize();
});
